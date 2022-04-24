def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end

def index()
    db = connect_to_db("db/database.db")

    return db.execute("SELECT * FROM title")
end

def login(username, password)
    db = connect_to_db("db/database.db")
    result = db.execute("SELECT * FROM user WHERE username = ?",username).first
    if result == nil
        @login_error = true
        slim(:login) 
    end
    pwdigest = result["pwdigest"]
    id = result["id"]
    auth = result["authority"]
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      session[:auth] = auth
      redirect('/')
    else
        @login_error = true
        slim(:login)
    end
end

def new_user_or_admin(username, password, password_confirm, auth)
    if(password == password_confirm)
        password_digest = BCrypt::Password.create(password)
        authority = auth
        db = connect_to_db("db/database.db")
        db.execute("INSERT INTO user (username,pwdigest,authority) VALUES (?,?,?)",username,password_digest,authority)
        redirect('/')
    elsif auth == 1
        @register_error = true
        slim(:user_register)
    elsif auth == 2
        @register_error = true
        slim(:admin_register)
    end
end

def genres()
    db = connect_to_db("db/database.db")
    return db.execute("SELECT * FROM genre")
end

def new_show()
    db = connect_to_db("db/database.db")

    return db.execute("SELECT * FROM genre")
end

def new_show_post(tvshow, genre_id, link)
    db = connect_to_db("db/database.db")
    db.execute("INSERT INTO title (name, genre_id, link) VALUES (?,?,?)",tvshow,genre_id,link)
end

def update()
    db = connect_to_db("db/database.db")
    return db.execute("SELECT * FROM title WHERE id=?", @editid).first
end

def update_post(tvshow, genre_id, link, editid)
    db = connect_to_db("db/database.db")
    db.execute("UPDATE title SET name = ?, genre_id = ?, link = ? WHERE id= ?",tvshow, genre_id, link, editid)
end

def delete(id)
    db = connect_to_db("db/database.db")
    db.execute("DELETE FROM title WHERE id='#{id}'")
end

def rate(rateid)
    db = connect_to_db("db/database.db")
    db.execute("SELECT * FROM title WHERE id=?", rateid).first
end

def rate_post(user_rate, title_id, user_id)
    db = connect_to_db("db/database.db")

    if db.execute("SELECT rating FROM user_title_relation WHERE user_id = ? AND title_id = ?", user_id, title_id)[0] == nil
        db.execute("INSERT INTO user_title_relation (rating, user_id, title_id) VALUES (?,?,?)", user_rate, user_id, title_id)
    else
        db.execute("UPDATE user_title_relation SET rating = ? WHERE user_id = ? AND title_id = ?", user_rate, user_id, title_id)
    end
end