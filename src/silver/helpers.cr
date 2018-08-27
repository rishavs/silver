module Silver
    class Form
        def self.get_params(body : IO)
            HTTP::Params.parse(body.gets_to_end)
        end
        def self.get_params(body : Nil)
            HTTP::Params.parse("")
        end
    end

    class ValidationError < Exception
    end
    
    class Validate
        def self.if_unique(itemval, itemname, dbtable)
            unq_count = (DB.scalar "select count(*) from #{dbtable} where #{itemname} = $1", itemval).as(Int)
            # pp unq_count.to_i
            if unq_count.to_i != 0
                raise ValidationError.new("The #{itemname} '#{itemval}' already exists.")
            end
        end
        def self.if_length(itemval, itemname, min, max)
            itemsize = itemval.size
            if !(min <= itemsize <= max)
                raise ValidationError.new("The #{itemname} (#{itemsize} chars) should be between #{min} and #{max} chars long.")
            end
        end
        def self.if_exists(itemval, itemname, dbtable)
            unq_count = (DB.scalar "select count(*) from #{dbtable} where #{itemname} = $1", itemval).as(Int)
            # pp unq_count.to_i
            if unq_count.to_i == 0
                raise ValidationError.new("The #{itemname} '#{itemval}' doesn't exists.")
            end
        end
        def self.if_loggedin(userHash)
            if userHash["loggedin"] != "true" || userHash["unqid"] == "none"
                raise ValidationError.new("Unable to fetch user details. Are you sure you are logged in?")
            end
        end
    end
end