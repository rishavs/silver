module Silver
    class Router
        def self.run(method, url, ctx)
            err         = nil
            currentuser = Auth.check(ctx)
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
                    redirect("/login", ctx)
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
                        redirect("/", ctx)
                    end
                end
            when { "GET", "logout", nil, nil}
                usercookie = Auth.logout(ctx)
                if usercookie
                    ctx.response.headers["Set-Cookie"] = usercookie.to_set_cookie_header
                    redirect("/", ctx)
                end

            # -------------------------------
            # Routes for Posts
            # -------------------------------
            when { "GET", "p", "new", nil}
                if currentuser
                    page = ECR.render("./src/silver/views/pages/Post_new.ecr")
                else
                    ctx.response.status_code = 401
                    page = ECR.render("./src/silver/views/pages/Error401.ecr")
                end

            when { "POST", "p", "new", nil}
                if currentuser
                    err, postid = Post.create(ctx)
                    if err || postid == nil
                        page = ECR.render("./src/silver/views/pages/Post_new.ecr")
                    else
                        redirect("/p/#{postid}", ctx)
                    end
                else
                    ctx.response.status_code = 401
                    page = ECR.render("./src/silver/views/pages/Error401.ecr")
                end

            when { "GET", "p", route.identifier, "like"}
                if currentuser
                    err, _ = Post.like(route.identifier, ctx)
                    redirect("/p/#{route.identifier}", ctx)
                else
                    ctx.response.status_code = 401
                    page = ECR.render("./src/silver/views/pages/Error401.ecr")
                end

            when { "GET", "p", route.identifier, "dislike"}
                if currentuser
                    err, _ = Post.dislike(route.identifier, ctx)
                    redirect("/p/#{route.identifier}", ctx)
                else
                    ctx.response.status_code = 401
                    page = ECR.render("./src/silver/views/pages/Error401.ecr")
                end

            when { "GET", "p", route.identifier, nil}
                err, post_data = Post.get(route.identifier)
                if post_data
                    page = ECR.render("./src/silver/views/pages/Post_show.ecr")
                else
                    ctx.response.status_code = 404
                    page = ECR.render("./src/silver/views/pages/Error404.ecr")
                end
                
            # -------------------------------
            # Routes for Users
            # -------------------------------
            # when { "GET", "u", "me", nil}
            #     page = ECR.render("./src/silver/views/pages/Post_new.ecr")
            when { "GET", "u", route.identifier, nil}
                if currentuser
                    err, user_data = User.get(route.identifier)
                    if user_data
                        page = ECR.render("./src/silver/views/pages/User.ecr")
                    else
                        page = ECR.render("./src/silver/views/pages/Error404.ecr")
                    end
                else
                    ctx.response.status_code = 401
                    page = ECR.render("./src/silver/views/pages/Error401.ecr")
                end
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
                ctx.response.status_code = 404
                page = ECR.render("./src/silver/views/pages/Error404.ecr")
            end

            # -------------------------------
            # Render selected page
            # -------------------------------

            navbar  = ECR.render("./src/silver/views/components/Navbar.ecr")
            flash   = ECR.render("./src/silver/views/components/Flash.ecr") 
            # ECR.embed "./src/silver/views/Layout.ecr", ctx.response
            ctx.response.print(ECR.render("./src/silver/views/Layout.ecr"))

        end

        def self.guard(currentuser, ctx)
            pp currentuser
            if !currentuser
                redirect("/login", ctx)
            end
        end
        def self.redirect(path, ctx)
            ctx.response.headers.add "Location", path
            ctx.response.status_code = 302
            # return
            # break
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