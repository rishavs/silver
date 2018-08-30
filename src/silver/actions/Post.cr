module Silver
    class Post

        # -------------------------------
        # Fetch a specific post
        # -------------------------------
        def self.get(postid) 
            begin
                # Get nil if the post doesnt exists. Else get the NamedTuple
                post = DB.query_one? "select unqid, title, content, link, liked_count, author_id, author_nick, created_at from posts where unqid = $1", postid, 
                as: {unqid: String, title: String, content: String, link: String, liked_count: Int, author_id: String, author_nick: String, created_at: Time}

            rescue ex
                pp ex
                if ex.message.to_s == "no rows"
                    err = "Are you sure you are looking for the right post?"
                else
                    err = ex.message.to_s
                end
            end
            return err, post
        end

        # -------------------------------
        # Fetch a list of posts
        # -------------------------------
        def self.get_list() 
            begin
                posts = DB.query_all "select unqid, title, content, link, author_id from posts",
                as: {unqid: String, title: String, content: String, link: String, author_id: String}
            rescue ex
                pp ex
                err = ex.message.to_s
            end
            return err, posts
        end
        
        # -------------------------------
        # Like a specific post via REST API
        # -------------------------------
        def self.like(postid, ctx) 
            currentuser = Auth.check(ctx)
            begin
                if currentuser
                    author_id = currentuser["unqid"]
                    author_nick = currentuser["nickname"]
                    author_flair = currentuser["flair"]
                else
                    raise AuthError.new("Unable to fetch user details. Are you sure you are logged in?")
                end

                DB.exec "UPDATE posts
                    SET liked_by = (select array_agg(distinct e) from unnest(liked_by || '{#{author_id}}') e),
                        liked_count = (select array_length(liked_by, 1) + 1)
                    WHERE
                        unqid = '#{postid}'"
            rescue ex
                pp ex
                err = ex.message.to_s
            end
            pp "Post #{postid} was liked by user #{author_nick} with the id #{author_id}"
            return err, nil
        end
        
        # -------------------------------
        # un-like a specific post via REST API
        # -------------------------------
        def self.unlike(postid, ctx) 
            currentuser = Auth.check(ctx)
            begin
                if currentuser
                    author_id = currentuser["unqid"]
                    author_nick = currentuser["nickname"]
                    author_flair = currentuser["flair"]
                else
                    raise AuthError.new("Unable to fetch user details. Are you sure you are logged in?")
                end

                DB.exec "UPDATE posts 
                    SET liked_by = array_remove(liked_by, '#{author_id}'),
                        liked_count = (select array_length(liked_by, 1) + 1)
                    WHERE unqid = '#{postid}'"
            rescue ex
                pp ex
                err = ex.message.to_s
            end
            pp "Post #{postid} was Un-liked by user #{author_nick} with the id #{author_id}"
            return err, nil
        end
        

        # -------------------------------
        # Create a new post
        # -------------------------------
        def self.create(ctx)
            currentuser = Auth.check(ctx)

            begin
                params = Form.get_params(ctx.request.body)
                title =  params.fetch("title")
                link =  params.fetch("link")
                content = params.fetch("content")
                if currentuser
                    author_id = currentuser["unqid"]
                    author_nick = currentuser["nickname"]
                    author_flair = currentuser["flair"]
                else
                    raise AuthError.new("Unable to fetch user details. Are you sure you are logged in?")
                end

                # Trim leading & trailing whitespace
                title = title.lstrip.rstrip
                link = link.lstrip.rstrip
                content = content.lstrip.rstrip

                # Validation checks
                Validate.if_length(title, "title", 3, 128)
                Validate.if_length(link, "link", 3, 1024)
                Validate.if_length(content, "content", 3, 2048)

                # Generate some data
                unqid = UUID.random.to_s
                
                # DB operations
                DB.exec "insert into posts (unqid, title, link, content, author_id, author_nick, author_flair) 
                    SELECT '#{unqid}', '#{title}', '#{link}', '#{content}', '#{author_id}', nickname, flair 
                    from users where unqid = '#{author_id}'"
            rescue ex
                pp ex
                err = ex.message.to_s
            else
                postid = unqid
            end
            return err, postid
        end
    end
end

