module Silver
    class Form
        def self.get_params(body : IO)
            HTTP::Params.parse(body.gets_to_end)
        end
        def self.get_params(body : Nil)
            HTTP::Params.parse("")
        end
    end
    
    class Timespan
        def self.humanize(t : Time)
            span = Time.utc_now - t
            mm, ss = span.total_seconds.divmod(60)            #=> [4515, 21]
            hh, mm = mm.divmod(60)           #=> [75, 15]
            dd, hh = hh.divmod(24)           #=> [3, 3]
            mo, dd = dd.divmod(30)           #=> [3, 3]
            yy, mo = mo.divmod(12)           #=> [3, 3]
            # puts "#{yy} years, #{mo} months, #{dd} days, #{hh} hours, #{mm} minutes and #{ss} seconds"
            if yy > 1
                return "#{yy} years ago"
            elsif yy == 1
                return "An year ago"
            elsif mo > 1 && mo < 13
                return "#{mo} months ago"
            elsif mo == 1
                return "A month ago"
            elsif dd > 1 && dd < 31
                return "#{dd} days ago"
            elsif dd == 1
                return "A day ago"
            elsif hh > 1 && hh < 25
                return "#{hh} hours ago"
            elsif hh == 1
                return "An hour ago"
            elsif mm > 5 && mm < 61
                return "#{mm} minutes ago"
            elsif mm <= 5
                return "Just now"
            else
                return "A while ago"
            end


            # pp span

            # pp span.days
            # pp span.hours
            # pp span.minutes
            # pp span.seconds

            # just now (<2 mins)
            # n minutes ago (< 60 mins)
            # n hours ago ( < 24 hours)
            # n days ago ()
            # n months ago
            # n years ago
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