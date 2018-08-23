# module Silver::Actions
    # class Post
    #     def self.render_new_post(ctx)
    #         # begin
    #         #     raise "This is an ERROR!!"
    #         # rescue ex
    #         #     pp ex
    #         #     err = ex.message.to_s
    #         # ensure
    #         #     pp err
    #             flash   = ECR.render("./src/silver/views/components/Flash.ecr") 
    #             page    = ECR.render("./src/silver/views/pages/Post_new.ecr")
    #             html    = ECR.render("./src/silver/views/Layout.ecr")

    #             ctx.response.content_type = "text/html; charset=utf-8"
    #             ctx.response.print(html)
    #         # end
    #     end

    # end
# end

module Silver::Render
    class Post_new

        def initialize()
            begin
                raise "This is an ERROR!!"
            rescue ex
                pp ex
                @err = ex.message.to_s
            end
        end

            @flash   = ECR.embed("./src/silver/views/components/Flash.ecr") 
            @page    = ECR.embed("./src/silver/views/pages/Post_new.ecr")
            html    = ECR.render("./src/silver/views/Layout.ecr")
            html
    end
end
