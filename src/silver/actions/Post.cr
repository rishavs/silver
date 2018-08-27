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
