module Silver
    class Migrate
        def self.create()

        end

        def self.delete()
            begin
                File.read("migrate/down.sql").split(';').each do |query|
                    if !query.starts_with?("--")
                        pp query
                        result = DB.exec (query)
                        pp result
                    end
                end
            rescue ex
                err = ex.message.to_s
                pp err
            else
                pp "Queries were successfully executed"
            end
        end

        def self.seed()

        end



    end


end