module Silver
    class User

        # -------------------------------
        # Fetch a specific user
        # -------------------------------
        def self.get(userid) 
            begin
                # Get nil if the user doesnt exists. Else get the NamedTuple
                user = DB.query_one? "select unqid, email, nickname, flair from users where unqid = $1", userid, 
                as: {unqid: String, email: String, nickname: String, flair: String}

            rescue ex
                pp ex
                if ex.message.to_s == "no rows"
                    err = "Are you sure you are looking for the right User?"
                else
                    err = ex.message.to_s
                end
            end
            return err, user
        end
    end
end
