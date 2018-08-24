module Silver
    class Router
        def self.run(method, url, ctx)
            err         = nil
            currentuser = nil
            route       = Route.new(url)

            case {method, route.resource, route.identifier, route.verb}

            when { "GET", "about", nil, nil}
                page = ECR.render("./src/silver/views/pages/About.ecr")

            when { "GET", "p", "new", nil}
                page = ECR.render("./src/silver/views/pages/Post_new.ecr")
            when { "GET", "p", route.identifier, nil}
                err, post_data = Post.get(route.identifier)
                pp err, post_data
                if post_data
                    page = ECR.render("./src/silver/views/pages/Post_show.ecr")
                else
                    page = ECR.render("./src/silver/views/pages/Error404.ecr")
                end

            # Catch-all routes    
            when { "GET", nil, nil, nil}
                page = ECR.render("./src/silver/views/pages/Home.ecr")
            else
                page = ECR.render("./src/silver/views/pages/Error404.ecr")
            end

            navbar  = ECR.render("./src/silver/views/components/Navbar.ecr")
            flash   = ECR.render("./src/silver/views/components/Flash.ecr") 
            # ECR.embed "./src/silver/views/Layout.ecr", ctx.response
            ctx.response.print(ECR.render("./src/silver/views/Layout.ecr"))

        end

        def self.redirect(path, ctx)
            ctx.response.headers.add "Location", path
            ctx.response.status_code = 302
        end

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
end