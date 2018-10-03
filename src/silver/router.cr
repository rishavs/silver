module Silver
    class Router
        def self.run(method, url, ctx)
            err         = nil
            currentuser = Auth.check(ctx)
            route       = Route.new(url)

            case {method, route.resource, route.identifier, route.verb, route.verb_identifier}

            # -------------------------------
            # Routes for Auth
            # # -------------------------------
            when { "GET", "register", nil, nil, nil}
                page = ECR.render("./src/silver/views/pages/Register.ecr")
            when { "POST", "register", nil, nil, nil}
                err, _ = Auth.register(ctx)
                if err
                    page = ECR.render("./src/silver/views/pages/Register.ecr")
                else
                    redirect("/login", ctx)
                end
            when { "GET", "login", nil, nil, nil}
                page = ECR.render("./src/silver/views/pages/Login.ecr")
            when { "POST", "login", nil, nil, nil}
                err, usercookie = Auth.login(ctx)
                if !err
                    if usercookie
                        ctx.response.headers["Set-Cookie"] = usercookie.to_set_cookie_header 
                        redirect("/", ctx)
                    end
                elsif err.starts_with?("Ban Hammer!")
                    ctx.response.headers["Set-Cookie"] = Auth.logout(ctx).to_set_cookie_header
                    page = ECR.render("./src/silver/views/pages/ErrorUserBanned.ecr")
                else
                    pp err
                    page = ECR.render("./src/silver/views/pages/Login.ecr")
                end

            when { "GET", "logout", nil, nil, nil}
                usercookie = Auth.logout(ctx)
                if usercookie
                    ctx.response.headers["Set-Cookie"] = usercookie.to_set_cookie_header
                    redirect("/", ctx)
                end

            # -------------------------------
            # Routes for Posts
            # -------------------------------
            when { "GET", "p", "new", nil, nil}
                if currentuser
                    _, tags_list = Tag.get_list()
                    page = ECR.render("./src/silver/views/pages/Post_new.ecr")
                else
                    ctx.response.status_code = 401
                    page = ECR.render("./src/silver/views/pages/Error401.ecr")
                end

            when { "POST", "p", "new", nil, nil}
                if currentuser
                    err, postid = Post.create(ctx)
                    if !err
                        redirect("/p/#{postid}", ctx)
                    elsif err.starts_with?("Ban Hammer!")
                        ctx.response.headers["Set-Cookie"] = Auth.logout(ctx).to_set_cookie_header
                        page = ECR.render("./src/silver/views/pages/ErrorUserBanned.ecr")
                    else
                        _, tags_list = Tag.get_list()
                        page = ECR.render("./src/silver/views/pages/Post_new.ecr")
                    end

                else
                    ctx.response.status_code = 401
                    page = ECR.render("./src/silver/views/pages/Error401.ecr")
                end

            when { "POST", "p", route.identifier, "like", nil}
                if currentuser
                    ctx.response.content_type = "application/json"
                    err, _ = Post.toggle_like(route.identifier, ctx)
                    if err
                        ctx.response.status_code = 500
                        ctx.response.print("{\"status\": \"error\", \"message\": \"#{err}\"}")
                        ctx.response.close
                    else
                        ctx.response.print("{\"status\": \"success\", \"message\": \"The post was sucessfully liked\"}")
                        ctx.response.close
                    end
                else
                    ctx.response.status_code = 401
                    ctx.response.print("{\"status\": \"error\", \"message\": \"Authorization error\"}")
                end

            when { "POST", "p", route.identifier, "upvote", route.verb_identifier}
                if currentuser
                    ctx.response.content_type = "application/json"
                    err, _ = Tag.upvote_tag_for_post(route.verb_identifier, route.identifier, ctx)
                    if err
                        ctx.response.status_code = 500
                        ctx.response.print("{\"status\": \"error\", \"message\": \"#{err}\"}")
                        ctx.response.close
                    else
                        ctx.response.print("{\"status\": \"success\", \"message\": \"The tag-post association was sucessfully upvoted\"}")
                        ctx.response.close
                    end
                else
                    ctx.response.status_code = 401
                    ctx.response.print("{\"status\": \"error\", \"message\": \"Authorization error\"}")
                end

            when { "POST", "p", route.identifier, "downvote", route.verb_identifier}
                if currentuser
                    ctx.response.content_type = "application/json"
                    err, _ = Tag.downvote_tag_for_post(route.verb_identifier, route.identifier, ctx)
                    if err
                        ctx.response.status_code = 500
                        ctx.response.print("{\"status\": \"error\", \"message\": \"#{err}\"}")
                        ctx.response.close
                    else
                        ctx.response.print("{\"status\": \"success\", \"message\": \"The tag-post association was sucessfully downvoted\"}")
                        ctx.response.close
                    end
                else
                    ctx.response.status_code = 401
                    ctx.response.print("{\"status\": \"error\", \"message\": \"Authorization error\"}")
                end


            when { "GET", "p", route.identifier, nil, nil}
                err, post_data, tags_data = Post.get(route.identifier)
                if post_data
                    page = ECR.render("./src/silver/views/pages/Post_show.ecr")
                else
                    ctx.response.status_code = 404
                    page = ECR.render("./src/silver/views/pages/Error404.ecr")
                end
                
            # -------------------------------
            # Routes for Tags
            # -------------------------------
            when { "POST", "t", "all", nil, nil}
            if currentuser
                ctx.response.content_type = "application/json"
                err, tags_list = Tag.get_list()
                if err
                    ctx.response.status_code = 500
                    ctx.response.print("{\"status\": \"error\", \"message\": \"#{err}\"}")
                    ctx.response.close
                else
                    # formatting for semantic-ui format
                    tags_json = JSON.build do |json|
                        json.object do
                            json.field "success", true
                            json.field "results" do
                                json.array do
                                    tags_list.try &.each do |t|
                                        json.object do
                                            json.field "name", t
                                            json.field "value", t 
                                        end
                                    end
                                end
                            end
                        end
                    end
                    ctx.response.print(tags_json)
                    ctx.response.close
                end
            else
                ctx.response.status_code = 401
                ctx.response.print("{\"status\": \"error\", \"message\": \"Authorization error\"}")
            end

            # -------------------------------
            # Routes for Users
            # -------------------------------
            # when { "GET", "u", "me", nil}
            #     page = ECR.render("./src/silver/views/pages/profile.ecr")
            when { "GET", "u", route.identifier, nil, nil}
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
            when { "GET", "about", nil, nil, nil}
                page = ECR.render("./src/silver/views/pages/About.ecr")
                
            # -------------------------------
            # Catch-all routes
            # -------------------------------
            when { "GET", nil, nil, nil, nil}
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
            if !ctx.response.closed?
                ctx.response.print(ECR.render("./src/silver/views/Layout.ecr"))
            end

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
        property resource :         String | Nil = nil
        property identifier :       String | Nil = nil
        property verb :             String | Nil = nil
        property verb_identifier :  String | Nil = nil
        
        def initialize(url : String)
            # Remove all leading and trailing whitespaces.
            url = url.lstrip(" / ").rstrip(" / ")
            arr = url.split("/")

            @resource =     arr[0]? && arr[0] != "" ? arr[0] : nil
            @identifier =   arr[1]? ? arr[1] : nil
            @verb =         arr[2]? ? arr[2] : nil
            @verb_identifier =         arr[3]? ? arr[3] : nil
        end
    end
end