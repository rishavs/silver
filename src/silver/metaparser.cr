require "http/client"


module Silver
    class MParser

        @image :        String: Nil = nil
        @description :  String: Nil = nil
        @favicon :      String: Nil = nil
        @title :        String: Nil = nil
        @url :          String: Nil = nil
        @err :          String: Nil = nil

        response = HTTP::Client.get "https://getbedtimestories.com/library/tate-s-time-traveling-top/"
        response.status_code      # => 200
        response.body.lines.first # => "<!doctype html>"

    end
end