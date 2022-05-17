require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'
enable :sessions

include Model

# Attempts to check if the client has authorization
before do
    if session[:auth] == nil && (request.path_info != '/login' && request.path_info != '/user' && request.path_info != '/showuserregister' && request.path_info != '/error' && request.path_info != '/' && request.path_info != '/showlogin' && request.path_info != '/admin' && request.path_info != '/showadminregister' && request.path_info != '/showaccount' && request.path_info != '/logout')
      redirect('/error')
    end
end

# Display Landing Page
# Displays all tv-shows
get("/") do
    @serier = index() 
    slim(:"serier/index")
end

# Displays an error message
get("/error") do
    slim(:error)
end

# Displays a register form
get('/showuserregister') do
    slim(:user_register)
end

# Displays a register form
get('/showadminregister') do
    slim(:admin_register)
end

# Displays a login form
get('/showlogin') do
    slim(:login)
end

#Displays user account
get('/showaccount') do
    id = session[:id]

    if id_nil(id)
        redirect('/error')
    end
    
    @your_account = account(id)
    @your_ratings = account_ratings(id)
    @titles = index()
    slim(:"serier/account")
end

# Login
post('/login') do
    if logTime(session[:stress], session[:timeLogged])
        username = params[:username]
        password = params[:password]
        sessions = login(username, password)

        if sessions == false
            redirect('/error')
        else
            session[:id] = sessions[0]
            session[:auth] = sessions[1]
        end
        redirect('/')
    else
        redirect('/showlogin')
    end
end


# Creates new user
# @param [String] username, the user username
# @param [String] password, the user password
# @param [String] password_confiem, the users confirmed password
post('/user') do
    if logTime(session[:stress], session[:timeLogged])
        username = params[:username]
        password = params[:password]
        password_confirm = params[:password_confirm]

        if isEmpty(username) || isEmpty(password) 
            redirect('/error')
        end
        if new_user_or_admin(username, password, password_confirm, 1) == false
            redirect('/error')
        end
        redirect('/')
    else
        redirect('/showuserregister')
    end
end

#Creates new admin user
# @param [String] username, the user username
# @param [String] password, the user password
# @param [String] password_confiem, the users confirmed password
post('/admin') do
    if logTime()
        username = params[:username]
        password = params[:password]
        password_confirm = params[:password_confirm]

        if isEmpty(username) || isEmpty(password) 
            redirect('/error')
        end
        if new_user_or_admin(username, password, password_confirm, 2) == false
            redirect('/error')
        end
        redirect('/')
    else
        redirect('/showadminregister')
    end
end

#Logs out from current user
get("/logout") do
    session[:id] = nil
    session[:auth] = nil
    redirect("/")
end

# Displays a form to post new tv-show
get("/new") do 
    @genres = genres()
    id = session[:id]

    if id_nil(id)
        redirect('/error')
    end
    
    slim(:"serier/new")
end

# Displays a edit tv-show form
get("/serier/:id/update") do
    @editid = params[:id]

    if ownership(session[:id], @editid, session[:auth], 2) == false
        redirect('/error')
    end

    @genres = genres()
    @edittitle = update()

    slim(:"serier/edit")
end

# Deletes an existing tv-show
post("/serier/:id/delete") do
    id = params[:id]

    if ownership(session[:id], id, session[:auth], 2) == false
        redirect('/error')
    end

    delete(id)
    
    redirect('/')  
end

# Deletes an existing rating
post("/serier/:title_id/rate_delete") do
    title_id = params[:title_id]
    user_id = session[:id]

    rate_delete(title_id, user_id)
    
    redirect("/showaccount")  
end

# Displays a rate tv-show form
get("/serier/:id/rate") do
    @rateid = params[:id]

    if session[:id] == nil 
        redirect('/error')
    end

    @ratetitle = rate(@rateid)

    slim(:"serier/rate")
end

# Creates a new movie
post("/tvshow") do
    tvshow = params[:tvshow]
    genre_id = params[:genre_id]
    link = params[:link]
    user_id = session[:id]

    if isEmpty(tvshow)
        redirect('/error')
    end

    new_show_post(tvshow, genre_id, link, user_id)

    redirect('/')
end

# Updates an existing tv-show
post('/serie/:editid/update') do
    tvshow = params[:newtvshowname]
    genre_id = params[:genre_id]
    link = params[:newlink]
    editid = params[:editid]

    if isEmpty(tvshow)
        redirect('/error')
    end

    update_post(tvshow, genre_id, link, editid)
    
    redirect('/')  
end

# Rating a existing tv-show
post('/serie/:rateid/rate') do
    user_rate = params[:user_rate]
    title_id = params[:rateid]
    user_id = session[:id]

    rate_post(user_rate, title_id, user_id)

    redirect('/')
end
