require "http/server"
require "dotenv"
require "pg"
require "ecr/macros"
require "crypto/bcrypt/password"
require "uuid"
require "jwt"
require "crog"
require "json"

require "./silver/*"
require "./silver/actions/*"

module Silver

    port = 3000
    host = "0.0.0.0"

  

    # uri = URI.parse "https://i.imgur.com/FvHh7EB.jpg"
    # uri = URI.parse "https://getbedtimestories.com/library/tate-s-time-traveling-top/"
    # mdata = Meta.new(uri)
    # pp mdata
    
    Dotenv.load
    DB = PG.connect ENV["DATABASE_URL"]
    # pp "Connecting to Database..."
    # pp DB.scalar "SELECT 'Connection established! The DB sends its regards.'"

    # Migrate.delete()
    # Migrate.create()
    # Migrate.seed()

    server = HTTP::Server.new([
        HTTP::ErrorHandler.new,
        HTTP::LogHandler.new,
        HTTP::StaticFileHandler.new("./public", fallthrough = true, directory_listing = false),
    ]) do |context|
        context.response.content_type = "text/html; charset=utf-8"    
        Router.run(context.request.method, context.request.resource, context)
    end

    # server.bind_tcp host, 8080
    puts "Server Started! Listening on #{host}:#{port}"
    server.listen(host, port)
end
