module Model    
    # Attempts to open a new database connection
    # @return [Array] containing all the data from the database
    def connect_to_db(path)
        db = SQLite3::Database.new(path)
        db.results_as_hash = true
        return db
    end

    #Attempts to select all tv-show
    # @update [Integer] containing the average rate of all rates on each tv-show
    # @return [Array] containing all the restaurants from the database
    # @see Model#connect_to_db

    def index()
        db = connect_to_db("db/database.db")
        titles = db.execute("SELECT * FROM title")
        titles.each do |title|
            avg_rate = db.execute("SELECT AVG(rating) FROM user_title_relation WHERE title_id = ?", title['id']).first['AVG(rating)']
            db.execute("UPDATE title SET avg_rate = ? WHERE id = ?",avg_rate, title['id'])
        end
        titles = db.execute("SELECT * FROM title")
        return titles
    end

    def average_rating()
        db = connect_to_db("db/database.db")
        db.execute("SELECT AVG(rating) FROM user_title_relation WHERE title_id = ?", title['id'])['AVG(rating)'].first
    end

    # Attempts to check if user can login
    # @see Model#connect_to_db
    def login(username, password)
        db = connect_to_db("db/database.db")
        result = db.execute("SELECT * FROM user WHERE username = ?",username).first
        if result == nil
            return false 
        end
        pwdigest = result["pwdigest"]
        id = result["id"]
        auth = result["authority"]
        if BCrypt::Password.new(pwdigest) == password
          return [id, auth]
        else
            return false
        end
    end

    # Attempts to check if too many inputs are recieved in close proximity
    # @param [Integer] latestTime, the latest logged time
    # @return [Boolean] whether the inputs are recieved in close proximity
    # @see Model#connect_to_db
    def logTime(stress, timeLogged)
        tempTime = Time.now.to_i

        if timeLogged == nil
            timeLogged = 0
        end
        difTime = tempTime - timeLogged

        if difTime < 1.5
            timeLogged = tempTime
            stress = true
            return false
        else
            timeLogged = tempTime
            stress = false
            return true
        end
    end

    # Attempts to register user
    # @param [String] password, the password input
    # @param [String] username, the user username
    # @return [Boolean] whether the user registration succeeds 
    # @see Model#connect_to_db
    def new_user_or_admin(username, password, password_confirm, auth)
        if(password == password_confirm)
            password_digest = BCrypt::Password.create(password)
            authority = auth
            db = connect_to_db("db/database.db")
            db.execute("INSERT INTO user (username,pwdigest,authority) VALUES (?,?,?)",username,password_digest,authority)
            return true
        else
            return false
        end
    end

    def authority(session_id, session_auth, required_session_id, required_session_auth)
        return session_id == required_session_id && session_auth == required_session_auth
    end

    # Attempts to check if the user is logged in or not
    # @return [Boolean] true if the user is not logged in and false if the user is logged in
    def id_nil(id)
        return id == nil
    end

    #Attempts to select all user info
    #@return [Hash] containing all user account information 
    def account(id)
        db = connect_to_db("db/database.db")
        return db.execute("SELECT * FROM user WHERE id = ?", id).first
    end

    #Attempts to select all the users ratings
    #@return [Hash] containing all the users ratings 
    def account_ratings(id)
        db = connect_to_db("db/database.db")
        return db.execute("SELECT * FROM user_title_relation WHERE user_id = ?", id)
    end
    
    #Attempts to select all the available genres
    #@return [Hash] containing all the available genres
    def genres()
        db = connect_to_db("db/database.db")
        return db.execute("SELECT * FROM genre")
    end

    # Attempts to create a new show in database
    def new_show_post(tvshow, genre_id, link, user_id)
        db = connect_to_db("db/database.db")
        db.execute("INSERT INTO title (name, genre_id, link, user_id) VALUES (?,?,?,?)",tvshow,genre_id,link,user_id)
    end

    # Attempts to retrieve all show info with a specified id
    #@return [Hash] containing all show info with a specified id
    def update()
        db = connect_to_db("db/database.db")
        return db.execute("SELECT * FROM title WHERE id=?", @editid).first
    end

    # Attempts to edit an existing show in database
    def update_post(tvshow, genre_id, link, editid)
        db = connect_to_db("db/database.db")
        db.execute("UPDATE title SET name = ?, genre_id = ?, link = ? WHERE id= ?",tvshow, genre_id, link, editid)
    end

    # Attempts to delete an existing show in database
    def delete(id)
        db = connect_to_db("db/database.db")
        db.execute("DELETE FROM title WHERE id='#{id}'")
        db.execute("DELETE FROM user_title_relation WHERE title_id='#{id}'")
    end

    def rate(rateid)
        db = connect_to_db("db/database.db")
        db.execute("SELECT * FROM title WHERE id=?", rateid).first
    end

    # Attempts to check if the user id is a owner of the show or if the user has the correct authorization
    # @return [Boolean] whetever the above stated is true
    def ownership(user_id, show_id, authority, exception_authority)
        db = connect_to_db("db/database.db")
        owner = db.execute("SELECT user_id FROM title WHERE id=?",show_id).first["user_id"]
        if user_id == owner || authority == exception_authority
            return true
        else
            return false
        end
    end

    def rate_post(user_rate, title_id, user_id)
        db = connect_to_db("db/database.db")

        if db.execute("SELECT rating FROM user_title_relation WHERE user_id = ? AND title_id = ?", user_id, title_id).first == nil
            db.execute("INSERT INTO user_title_relation (rating, user_id, title_id) VALUES (?,?,?)", user_rate, user_id, title_id)
        else
            db.execute("UPDATE user_title_relation SET rating = ? WHERE user_id = ? AND title_id = ?", user_rate, user_id, title_id)
        end
    end

    def rate_delete(title_id, user_id)
        db = connect_to_db("db/database.db")
        db.execute("DELETE FROM user_title_relation WHERE title_id = ? AND user_id = ?", title_id, user_id) 
    end
end

def isEmpty(text)
    if text == nil
        return true
    elsif text == "" || text.scan(/ /).empty? == false 
        return true
    else
        return false
    end
end