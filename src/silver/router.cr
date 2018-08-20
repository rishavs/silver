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
            store = Silver::Store.new
            route = Route.new(url)

            case {method, route.resource, route.identifier, route.verb}

            when { "GET", "p", route.identifier, nil}
                page = ECR.def_to_s "./silver/views/pages/Home.ecr"
                ctx.response.print ECR.def_to_s "./silver/views/Layout.ecr"

            # Catch-all routes    
            when { "GET", nil, nil, nil}
                ctx.response.print "HOME"
            else
                ctx.response.print "Yo dis 404"
            end

        end

        def self.redirect(path, ctx)
            ctx.response.headers.add "Location", path
            ctx.response.status_code = 302
        end

    end
end