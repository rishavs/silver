module Silver::Actions
    class Post
        def self.render_new_post(ctx)
            begin
                raise "This is an ERROR!!"
            rescue ex
                pp ex
                err = ex.message.to_s
            ensure
                pp err

                # page    = ECR.render("./src/silver/views/pages/Post_new.ecr")
                # html    = ECR.render("./src/silver/views/Layout.ecr")

                ctx.response.content_type = "text/html; charset=utf-8"
                ctx.response.print(flash)
            end
        end

    end
end
