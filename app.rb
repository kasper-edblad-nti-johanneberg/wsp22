require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'
enable :sessions

get("/") do
    @serier = index() 
    slim(:"serier/index")
end

get('/showuserregister') do
    slim(:user_register)
end

get('/showadminregister') do
    slim(:admin_register)
end

get('/showlogin') do
    slim(:login)
end
  
post('/login') do
    username = params[:username]
    password = params[:password]
    login(username, password)
    redirect('/')
end
  

post('/usernew') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    new_user_or_admin(username, password, password_confirm, 1)
end

post('/adminnew') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    new_user_or_admin(username, password, password_confirm, 2)
end

get("/logout") do
    session[:id] = nil
    session[:auth] = nil
    redirect("/")
end

get("/new") do 
    @genres = new_show()

    slim(:"serier/new")
end

get("/serier/:id/update") do
    @editid = params[:id]

    @genres = genres()
    @edittitle = update()
    
    slim(:"serier/edit")
end

post("/serier/:id/delete") do
    id = params[:id]

    delete(id)
    
    redirect('/')  
end

get("/serier/:id/rate") do
    @rateid = params[:id]
    @ratetitle = rate(@rateid)

    slim(:"serier/rate")
end

post("/newtvshow") do
    tvshow = params[:tvshow]
    genre_id = params[:genre_id]
    link = params[:link]

    new_show_post(tvshow, genre_id, link)

    redirect('/')
end

post('/serie/:editid/update') do
    tvshow = params[:newtvshowname]
    genre_id = params[:genre_id]
    link = params[:newlink]
    editid = params[:editid]

    update_post(tvshow, genre_id, link, editid)
    
    redirect('/')  
end

post('/serie/:rateid/rate') do
    user_rate = params[:user_rate]
    title_id = params[:rateid]
    user_id = session[:id]

    rate_post(user_rate, title_id, user_id)

    redirect('/')
end
