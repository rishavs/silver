module Silver
    class Tag

        # -------------------------------
        # Fetch the full list of tags
        # -------------------------------
        def self.get_list() 
            begin
                tags = DB.query_all "select DISTINCT name from tags",
                as: {name: String}
            rescue ex
                pp ex
                err = ex.message.to_s
            end
            return err, tags
        end

        # -------------------------------
        # Upvote tag-post association
        # -------------------------------
        def self.upvote_tag_for_post(tag_name, postid, ctx) 
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
                        select into vt voted from tags where name ='#{tag_name}' and post_id = '#{postid}' and author_id = '#{author_id}';
                        CASE vt
                        WHEN 'up' THEN
                            delete from tags where name ='#{tag_name}' and post_id = '#{postid}' and author_id = '#{author_id}';
                        WHEN 'down' THEN
                            update tags set voted = 'up' where name ='#{tag_name}' and post_id = '#{postid}' and author_id = '#{author_id}';
                        ELSE
                            insert into tags (name, post_id, author_id, voted) values ('#{tag_name}', '#{postid}', '#{author_id}', 'up');
                        END CASE;
                    END
                    $$;"

            rescue ex
                pp ex
                err = ex.message.to_s
            end
            pp "Tag #{tag_name} was Upvoted by user #{author_nick} for Post #{postid} "
            return err, nil
        end

        # -------------------------------
        # Downvote tag-post association
        # -------------------------------
        def self.downvote_tag_for_post(tag_name, postid, ctx) 
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
                        select into vt voted from tags where name ='#{tag_name}' and post_id = '#{postid}' and author_id = '#{author_id}';
                        CASE vt
                        WHEN 'down' THEN
                            delete from tags where name ='#{tag_name}' and post_id = '#{postid}' and author_id = '#{author_id}';
                        WHEN 'up' THEN
                            update tags set voted = 'down' where name ='#{tag_name}' and post_id = '#{postid}' and author_id = '#{author_id}';
                        ELSE
                            insert into tags (name, post_id, author_id, voted) values ('#{tag_name}', '#{postid}', '#{author_id}', 'down');
                        END CASE;
                    END
                    $$;"

            rescue ex
                pp ex
                err = ex.message.to_s
            end
            pp "Tag #{tag_name} was Upvoted by user #{author_nick} for Post #{postid} "
            return err, nil
        end

    end
end