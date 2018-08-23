require "http/server"
require "dotenv"
require "db"
require "pg"
require "ecr/macros"

require "crypto/bcrypt/password"

require "./silver/*"
require "./silver/actions/*"


module Silver
    port = 3000
    host = "0.0.0.0"
    
    Dotenv.load

    DB = PG.connect ENV["DATABASE_URL"]
    pp "Connecting to Database..."
    pp DB.scalar "SELECT 'Connection established! The DB sends its regards.'"

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
