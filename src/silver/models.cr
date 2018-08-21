module Silver::Models
    class CommentTree
        property unqid : String
        property parent_id : String
        property level : Int32
        property post_id : String
        property content : String
        property author_id : String
        property author_nick : String
        property author_flair : String | Nil
        property children_ids = [] of String
      
        def initialize(@unqid, @level,  @post_id, @parent_id, @content, @author_id, @author_nick)
        end
    end

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
    end

    class User
        property unqid : String
        property email : String
        property password : String
        property nickname : Int32
        property flair : String
      
        def initialize(@unqid, @email,  @password, @nickname, @flair)
        end
    end

end
