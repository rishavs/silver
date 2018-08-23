module Silver

    class Store 
        property status :       String | Nil = nil
        property message :      String | Nil = nil
        property currentuser :  Hash(String, String) | Nil = nil      #/{"unqid" => "someid", "nickname" => "somenick" }
    end

    class Route 
        property resource :     String | Nil = nil
        property identifier :   String | Nil = nil
        property verb :         String | Nil = nil
        
        def initialize(url : String)
            # Remove all leading and trailing whitespaces.
            url = url.lstrip(" / ").rstrip(" / ")
            arr = url.split("/")

            @resource =     arr[0]? && arr[0] != "" ? arr[0] : nil
            @identifier =   arr[1]? ? arr[1] : nil
            @verb =         arr[2]? ? arr[2] : nil

        end
    end

    class Router
        def self.run(method, url, ctx)
            store = Store.new
            route = Route.new(url)

            case {method, route.resource, route.identifier, route.verb}

            when { "GET", "about", nil, nil}
                page = ECR.render("./src/silver/views/pages/About.ecr")
                html = ECR.render("./src/silver/views/Layout.ecr")
                ctx.response.print(html)

            when { "GET", "p", "new", nil}
                Actions::Post.render_new_post(ctx)
                ctx.response.print(Render::Post_new.new.to_s)
            when { "GET", "p", route.identifier, nil}
                page = ECR.render("./src/silver/views/pages/Post_show.ecr")
                html = ECR.render("./src/silver/views/Layout.ecr")
                ctx.response.print(html)

            # when { "GET", "c", "new", nil}
            #     Actions::Post.render_new_post(ctx)

            # Catch-all routes    
            when { "GET", nil, nil, nil}
                page = ECR.render("./src/silver/views/pages/Home.ecr")
                html = ECR.render("./src/silver/views/Layout.ecr")
                ctx.response.print(html)
            else
                page = ECR.render("./src/silver/views/pages/Error404.ecr")
                html = ECR.render("./src/silver/views/Layout.ecr")
                ctx.response.print(html)
            end

        end

        def self.redirect(path, ctx)
            ctx.response.headers.add "Location", path
            ctx.response.status_code = 302
        end

    end
end