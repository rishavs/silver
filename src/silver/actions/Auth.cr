module Silver
    class Auth

        def self.register(ctx) 
            begin
                # post = Post.from_rs(DB.query("select unqid, title, content, link, author_id, author_nick 
                # from posts where unqid = $1 limit 1", postid))

                params =    Parse.form_params(ctx.request.body)
                nickname =  params.fetch("nickname")
                flair =  params.fetch("flair")
                email =  params.fetch("email")
                password =  params.fetch("password")
                
                # Trim leading & trailing whitespace
                email = email.downcase.lstrip.rstrip
                nickname = nickname.lstrip.rstrip
                flair = flair.lstrip.rstrip

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
            ensure
                val = nil
            end
            return err, val
        end

        def self.register()
            
            begin
                params = Form.get_params(ctx.request.body)
                nickname =  params.fetch("nickname")
                flair =  params.fetch("flair")
                email =  params.fetch("email")
                password =  params.fetch("password")
                
                # Trim leading & trailing whitespace
                email = email.downcase.lstrip.rstrip
                nickname = nickname.lstrip.rstrip
                flair = flair.lstrip.rstrip

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
                pp ex
                store.status = "error"
                store.message = ex.message.to_s

                ctx.response.content_type = "text/html; charset=utf-8"    
                ctx.response.print Layout.render( store, Views.register)
            else
                store.status = "success"
                store.message = "User was success fully added"

            end
        end
    end

end