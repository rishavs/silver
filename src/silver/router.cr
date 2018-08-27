module Silver
    class Router
        def self.run(method, url, ctx)
            err         = nil
            currentuser = nil
            route       = Route.new(url)

            case {method, route.resource, route.identifier, route.verb}

            # -------------------------------
            # Routes for Auth
            # # -------------------------------
            when { "GET", "register", nil, nil}
                page = ECR.render("./src/silver/views/pages/Register.ecr")
            when { "POST", "register", nil, nil}
                err, _ = Auth.register(ctx)
                if err
                    page = ECR.render("./src/silver/views/pages/Register.ecr")
                else
                    Router.redirect("/login", ctx)
                end
            when { "GET", "login", nil, nil}
                page = ECR.render("./src/silver/views/pages/Login.ecr")
            when { "POST", "login", nil, nil}
                err, usercookie = Auth.login(ctx)
                if err
                    page = ECR.render("./src/silver/views/pages/Login.ecr")
                else
                    if usercookie
                        ctx.response.headers["Set-Cookie"] = usercookie.to_set_cookie_header 
                        Router.redirect("/", ctx)
                    end
                end
            when { "GET", "logout", nil, nil}
                usercookie = Auth.logout(ctx)
                if usercookie
                    ctx.response.headers["Set-Cookie"] = usercookie.to_set_cookie_header
                    Router.redirect("/", ctx)
                end

            # -------------------------------
            # Routes for Posts
            # -------------------------------
            when { "GET", "p", "new", nil}
                page = ECR.render("./src/silver/views/pages/Post_new.ecr")
            when { "POST", "p", "new", nil}
                err, postid = Post.create(ctx)
                if err
                    page = ECR.render("./src/silver/views/pages/Post_new.ecr")
                else
                    if postid
                        Router.redirect("/p/#{postid}", ctx)
                    end
                end
            when { "GET", "p", route.identifier, nil}
                err, post_data = Post.get(route.identifier)
                # pp err, post_data
                if post_data
                    page = ECR.render("./src/silver/views/pages/Post_show.ecr")
                else
                    page = ECR.render("./src/silver/views/pages/Error404.ecr")
                end

            # -------------------------------
            # Routes for Users
            # -------------------------------
            # when { "GET", "u", "me", nil}
            #     page = ECR.render("./src/silver/views/pages/Post_new.ecr")
            # when { "GET", "u", route.identifier, nil}
            #     err, post_data = Post.get(route.identifier)
            #     # pp err, post_data
            #     if post_data
            #         page = ECR.render("./src/silver/views/pages/Post_show.ecr")
            #     else
            #         page = ECR.render("./src/silver/views/pages/Error404.ecr")
            #     end

            # -------------------------------
            # Misc routes
            # -------------------------------
            when { "GET", "about", nil, nil}
                page = ECR.render("./src/silver/views/pages/About.ecr")
                
            # -------------------------------
            # Catch-all routes
            # -------------------------------
            when { "GET", nil, nil, nil}
                err, posts_list = Post.get_list()
                page = ECR.render("./src/silver/views/pages/Home.ecr")
            else
                page = ECR.render("./src/silver/views/pages/Error404.ecr")
            end

            # -------------------------------
            # Render selected page
            # -------------------------------
            currentuser = Auth.check(ctx)
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