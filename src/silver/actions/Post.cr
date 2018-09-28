module Silver
    class Post

        # -------------------------------
        # Fetch a specific post
        # -------------------------------
        def self.get(postid) 
            err = nil
            begin
                # Get nil if the post doesnt exists. Else get the NamedTuple
                post = DB.query_one? "select unqid, title, content, link, liked_count, author_id, author_nick, created_at from posts 
                    where unqid = $1", postid, 
                as: {unqid: String, title: String, content: String, link: String, liked_count: Int, author_id: String, author_nick: String, created_at: Time}

                tags = DB.query_all "select name,  
                    (select 
                        (
                            COUNT(voted) filter (where voted = 'up') -
                            COUNT(voted) filter (where voted = 'down')
                        ) as vcount )
                    from tags where post_id = '#{postid}'
                    group by name;", 
                    as: {name: String, count: Int}

            rescue ex
                pp ex
                if ex.message.to_s == "no rows"
                    err = "Are you sure you are looking for the right post?"
                else
                    err = ex.message.to_s
                end
            end
            return err, post, tags
        end

        # -------------------------------
        # Fetch a list of posts
        # -------------------------------
        def self.get_list() 
            err = nil
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
        # Toggle like a specific post via REST API
        # -------------------------------
        def self.toggle_like(postid, ctx) 
            err = nil
            currentuser = Auth.check(ctx)
            begin
                if currentuser
                    author_id = currentuser["unqid"]
                    author_nick = currentuser["nickname"]
                    author_flair = currentuser["flair"]
                else
                    raise AuthError.new("Unable to fetch user details. Are you sure you are logged in?")
                end

                DB.exec "DO
                    $$
                    DECLARE 
                        vt   votetype;
                    BEGIN
                        select into vt voted from like_posts where post_id = '#{postid}' and author_id = '#{author_id}';
                        CASE vt
                        WHEN 'up' THEN
                            delete from like_posts where post_id = '#{postid}' and author_id = '#{author_id}';
                        ELSE
                            insert into like_posts (post_id, author_id, voted, voteint) values ('#{postid}', '#{author_id}', 'up');
                        END CASE;
                        
                        update posts 
                        set liked_count = (
                            select (
                                COUNT(voted) filter (where voted = 'up') -
                                COUNT(voted) filter (where voted = 'down')
                            ) 
                            from like_posts where post_id = '#{postid}'
                        )
                        where unqid = '#{postid}';
                    END
                    $$;"

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
            err = nil
            currentuser = Auth.check(ctx)

            begin
                params  = Form.get_params(ctx.request.body)
                title   =  params.fetch("title")
                link    =  params.fetch("link")
                content = params.fetch("content")
                tags    = params.fetch_all("tags")

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
                Validate.if_arr_length(tags, "tags", 1, 3)

                # Generate some data
                unqid = UUID.random.to_s

                # create the tags_val string
                tags_list_string = tags.try &.map {|t| "('#{t}', '#{unqid}', '#{author_id}', 'up')"}.join(", ")

                # DB operations
                query = "DO
                    $$
                    BEGIN
                        IF (select banned_till from users where unqid = '#{author_id}') > now() THEN
                            RAISE EXCEPTION 'Ban Hammer!';
                        ELSE 
                            IF (with to_check (itag) as ( values #{tags_list_string} )
                                select bool_and(exists (select * from tags t where t.name = tc.itag)) as all_tags_present
                                from to_check tc) 
                            THEN
                                insert into tags (name, post_id, author_id, voted) values #{tags_list_string};
                                insert into posts (unqid, title, link, content, author_id, author_nick, author_flair) 
                                    SELECT '#{unqid}', '#{title}', '#{link}', '#{content}', '#{author_id}', nickname, flair 
                                    from users where unqid = '#{author_id}';
                            ELSE
                                RAISE EXCEPTION 'Fake tags!';
                            END IF;
                        END IF;
                    END
                    $$;"
                # pp query
                DB.exec query
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

