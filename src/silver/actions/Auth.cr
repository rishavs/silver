module Silver
    class Auth
        def self.register(ctx : HTTP::Server::Context) 
            begin
                params =    Form.get_params(ctx.request.body)
                nickname =  params.fetch("nickname")
                flair =     params.fetch("flair")
                email =     params.fetch("email")
                password =  params.fetch("password")
                
                # Trim leading & trailing whitespace
                email =     email.downcase.lstrip.rstrip
                nickname =  nickname.lstrip.rstrip
                flair =     flair.lstrip.rstrip
    
                # Validation checks
                Validate.if_length(email, "email", 3, 32)
                Validate.if_length(password, "password", 3, 32)
                Validate.if_unique(email, "email", "users")
    
                # Generate some data
                unqid = UUID.random.to_s
                password = Crypto::Bcrypt::Password.create(password).to_s
                
                # DB operations
                DB.exec "insert into users (unqid, nickname, flair, email, password) values ($1, $2, $3, $4, $5)", 
                    unqid, nickname, flair, email, password
            rescue ex
                err = ex.message.to_s
                pp err
            end
            return err, nil
        end
        
        def self.login(ctx : HTTP::Server::Context)

            begin
                params =    Form.get_params(ctx.request.body)
                email =     params.fetch("email")
                password =  params.fetch("password")
                
                # Trim leading & trailing whitespace
                email = email.downcase.lstrip.rstrip

                # Validation checks
                Validate.if_length(email, "email", 3, 32)
                Validate.if_length(password, "password", 3, 32)

                user = DB.query_one "select unqid, nickname, flair, email, password from users where email = $1", email, 
                    as: {unqid: String, nickname: String, flair: String, email: String, password: String}
            
            rescue ex
                pp ex
                if ex.message.to_s == "no rows"
                    puts "The User DOESN'T exists"
                    err = "The entered email or password is wrong"
                else
                    err = ex.message.to_s
                end
            else
                if Crypto::Bcrypt::Password.new(user["password"].to_s) == password
                    puts "The password matches"

                    exp = Time.now.epoch + 6000000
                    payload = { "unqid" => user["unqid"], 
                        "email" => user["email"], 
                        "nickname" => user["nickname"], 
                        "flair" => user["flair"], 
                        "exp" => exp }
                    token = JWT.encode(payload, ENV["SECRET_JWT"], "HS256")

                    usercookie = HTTP::Cookie.new("usertoken", token, "/", Time.now + 12.hours)
                    # ctx.response.headers["Set-Cookie"] = usercookie.to_set_cookie_header
                else 
                    puts "The password DOESN'T matches"
                    err = "The entered email or password is wrong"
                    usercookie = nil
                end
            end

            return err, usercookie
        end

        def self.logout(ctx : HTTP::Server::Context)
            usercookie = HTTP::Cookie.new("usertoken", "none", "/", Time.now + 12.hours)
            usercookie
        end

        def self.check(ctx : HTTP::Server::Context)
            if ctx.request.cookies.has_key?("usertoken") && ctx.request.cookies["usertoken"].value != "none"
                token = ctx.request.cookies["usertoken"].value
                currentuser = check_token(token)
            end
            return currentuser
        end

        def self.check_token(token : String)
            payload, header = JWT.decode(token, ENV["SECRET_JWT"], "HS256")
            currentuser = { 
                "unqid" => payload["unqid"].to_s, 
                "email" => payload["email"].to_s,
                "nickname" => payload["nickname"].to_s,
                "flair" => payload["flair"].to_s,
            }
            return currentuser
        end
    end
end
