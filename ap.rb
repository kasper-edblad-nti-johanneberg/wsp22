require 'sinatra'
require 'slim'
require 'sqlite3'

enable :sessions

def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end


get("/") do
    db = connect_to_db("db/database.db")
    serier = db.execute("SELECT * FROM title")
    p serier
    slim(:"serier/index", locals:{serier:serier})
end

get("/new") do 
    slim(:"serier/new")
end

post("/newtvshow") do
    tvshow = params[:tvshow]
    genre = params[:genre]

    db = connect_to_db("db/database.db")
    db.execute("INSERT INTO title (name) VALUES (?)",tvshow)
    db.execute("INSERT INTO genre (genrename) VALUES (?)",genre)
    db.execute("INSERT INTO genre (genrename) VALUES (?)",genre)

    
    redirect('/')  
end
