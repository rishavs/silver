module Silver
    class Tag

        # -------------------------------
        # Fetch the full list of tags
        # -------------------------------
        def self.get_list() 
            begin
                tags = DB.query_all "select name from tags",
                as: {name: String}
            rescue ex
                pp ex
                err = ex.message.to_s
            end
            return err, tags
        end

    end
end