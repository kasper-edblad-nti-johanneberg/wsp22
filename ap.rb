require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end

get("/") do

    db = connect_to_db("db/database.db")
    @serier = db.execute("SELECT * FROM title")
    
    slim(:"serier/index")
end

get('/showregister') do
    slim(:register)
end

get('/showlogin') do
    slim(:login)
end
  
post('/login') do
    username = params[:username]
    password = params[:password]
    
    db = connect_to_db("db/database.db")
    
    result = db.execute("SELECT * FROM user WHERE username = ?", username).first
    pwdigest = result["pwdigest"]
    id = result["id"]
    
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      redirect('/')
    else
      "Fel lösenord!"
    end
end
  

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    if(password == password_confirm)
      password_digest = BCrypt::Password.create(password)
      db = connect_to_db("db/database.db")
      db.execute("INSERT INTO user (username,pwdigest) VALUES (?,?)",username,password_digest)
      redirect('/')
    else
      "Lösenorden matchade inte"
    end
end

get("/new") do 
    db = connect_to_db("db/database.db")
    @genres = db.execute("SELECT * FROM genre")

    slim(:"serier/new")
end

get("/serier/update/:id") do
    @editid = params[:id]
     
    db = connect_to_db("db/database.db")
    @genres = db.execute("SELECT * FROM genre")
    @edittitle = db.execute("SELECT * FROM title WHERE id=?", @editid).first
    p @edittitle
    

    slim(:"serier/edit")
end

post("/serier/delete/:id") do
    id = params[:id]
    
    db = connect_to_db("db/database.db")
    db.execute("DELETE FROM title WHERE id='#{id}'")
    redirect('/')  
end

get("/serier/rate/:id") do
    @rateid = params[:id]
    @ratetitle = db.execute("SELECT * FROM title WHERE id=?", @rateid).first

    p @ratetitle

    slim(:"serier/rate")
end

post("/newtvshow") do

    db = connect_to_db("db/database.db")

    tvshow = params[:tvshow]
    genre_id = params[:genre_id]
    link = params[:link]

    db.execute("INSERT INTO title (name, genre_id, link) VALUES (?,?,?)",tvshow,genre_id,link)
    #db.execute("INSERT INTO genre (genrename) VALUES (?)",genre)
    #db.execute("INSERT INTO genre (genre_id) VALUES (?)",genre_id)
    
    redirect('/')  
end

post('/serie/:editid/update') do

    db = connect_to_db("db/database.db")

    tvshow = params[:newtvshowname]
    genre_id = params[:genre_id]
    link = params[:newlink]
    editid = params[:editid]

    db.execute("UPDATE title SET name = ?, genre_id = ?, link = ? WHERE id= ?",tvshow, genre_id, link, editid)
    #db.execute("INSERT INTO genre (genrename) VALUES (?)",genre)
    #db.execute("INSERT INTO genre (genre_id) VALUES (?)",genre_id)
    
    redirect('/')  
end

post('/serie/:rateid/rate') do
    db = connect_to_db("db/database.db")
    user_rate = params[:user_rate]

    p db.execute("SELECT user_id FROM user_title_relation WHERE EXISTS user_id = ?", session[:id])

    db.execute("")

end
