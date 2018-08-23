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
      
        def initialize(@unqid, @title, @content)
        end

        def self.get(postid) 
            if postid
                postObj = Post.from_rs(DB.query("select unqid, title, content, link, author_id, author_nick 
                from posts where unqid = $1", postid))
                pp postObj
                return postObj[0]
            end
        end

    end

end
