module Silver
    class Post
        def self.get(postid) 
            begin
                # Get nil if the post doesnt exists. Else get the NamedTuple
                post = DB.query_one? "select unqid, title, content, link, author_id, author_nick from posts where unqid = $1", postid, 
                as: {unqid: String, title: String, content: String, link: String, author_id: String, author_nick: String}
            rescue ex
                err = ex.message.to_s
                pp err
            end
            return err, post
        end

        def self.get_list() 
            begin
                posts = DB.query_all "select unqid, title, content, link, author_id from posts",
                as: {unqid: String, title: String, content: String, link: String, author_id: String}
            rescue ex
                err = ex.message.to_s
                pp err
            end
            return err, posts
        end

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
                    raise Exception.new("Unable to fetch user details. Are you sure you are logged in?")
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



# module Silver
#     class Post < Granite::Base
#         adapter pg

#         primary unqid :         String, auto: false
#         field! title :          String
#         field content :         String
#         field link :            String
#         field thumb :           String
#         field! author_id :      String
#         field! author_nick :    String
#         field! author_flair :   String

#         timestamps

#         before_create :assign_unqid
#         def assign_unqid
#             @unqid = UUID.random.to_s
#         end

#         # validate_min_length :title, 3
#         # validate_max_length :title, 255

#         def self.get(postid) 
#             begin
#                 post = Post.find postid
#             rescue ex
#                 err = ex.message.to_s
#                 pp err
#             end
#             return err, post
#         end

#         def self.get_list() 
#             begin
#                 posts = Post.all("ORDER BY created_at DESC")
#             rescue ex
#                 err = ex.message.to_s
#                 pp err
#             end
#             return err, posts
#         end
#     end
# end
