module Silver
    class Post
        DB.mapping({
            unqid: String,
            title: String,
            link: {
                type:    String,
                nilable: true
            },
            content: String,
            author_id: String,
            author_nick: String,
            author_flair: {
                type:    String,
                nilable: true
            }
        })
      
        # def initialize(@unqid, @title, @content)
        # end

        def self.get(postid) 
            begin
                err = nil
                post = Post.from_rs(DB.query("select unqid, title, content, link, author_id, author_nick 
                from posts where unqid = $1 limit 1", postid))
            rescue ex
                err = ex.message.to_s
                pp err
            ensure
                val = post && !post.empty? ? post[0] : nil
            end
            return err, val
        end

        def self.get_list() 
            begin
                err = nil
                posts = Post.from_rs(DB.query("select unqid, title, content, link, author_id, author_nick 
                from posts"))
            rescue ex
                err = ex.message.to_s
                pp err
            ensure
                val = posts
            end
            return err, val
        end

    end

end
