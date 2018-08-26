require "http/server"
require "dotenv"
require "pg"
require "granite/adapter/pg"
require "ecr/macros"
require "crypto/bcrypt/password"

Dotenv.load
Granite::Adapters << Granite::Adapter::Pg.new({name: "pg", url: ENV["DATABASE_URL"]})

require "./silver/*"
require "./silver/actions/*"

module Silver

    port = 3000
    host = "0.0.0.0"

    Post.migrator.drop_and_create

    server = HTTP::Server.new([
        HTTP::ErrorHandler.new,
        HTTP::LogHandler.new,
    ]) do |context|
        context.response.content_type = "text/html; charset=utf-8"    
        Router.run(context.request.method, context.request.resource, context)
    end

    # server.bind_tcp host, 8080
    puts "Server Started! Listening on #{host}:#{port}"
    server.listen(host, port)
end
