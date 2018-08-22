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
      
        def initialize(@unqid, @title,  @link, @content, @author_id, @author_nick, @author_flair)
        
        end

        def get()

        end
    end

    class Posts


        def get_list()

        end

    end


end
