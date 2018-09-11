module Silver
    class Form
        def self.get_params(body : IO)
            HTTP::Params.parse(body.gets_to_end)
        end
        def self.get_params(body : Nil)
            HTTP::Params.parse("")
        end
    end
    
    class Meta

        property image :        String | Nil = nil
        property image_width :  Int32 | Nil = nil
        property image_height : Int32 | Nil = nil
        property url :          String | Nil = nil
        property description :  String | Nil = nil
        property title :        String | Nil = nil
        property author :       String | Nil = nil
        property date :         String | Nil = nil
        property logo :         String | Nil = nil
        property tags         = [] of String

        def initialize(@site : String)
    
            HTTP::Client.get(site) do |res_io|
                res_io.status_code  # => 200
                document = XML.parse_html(res_io.body_io)

                @image         = get_image(document)
                @image_height  = document.xpath_node("//meta[@property='og:image:height']").try &.["content"].to_i
                @image_width   = document.xpath_node("//meta[@property='og:image:width']").try &.["content"].to_i
                @url           = get_url(document)
                @description   = get_description(document)
                @title         = get_title(document)
                @date          = get_date(document)
                @logo          = get_logo(document)
                @tags          = get_tags(document)
            end
        end

        def get_image(node : XML::Node)
            image = node.xpath_node("//meta[@property='og:image:secure_url']").try &.["content"].to_s || 
                node.xpath_node("//meta[@property='og:image:url']").try &.["content"].to_s || 
                node.xpath_node("//meta[@property='og:image']").try &.["content"].to_s || 
                node.xpath_node("//meta[@name='twitter:image:src']").try &.["content"].to_s || 
                node.xpath_node("//meta[@name='twitter:image']").try &.["content"].to_s ||
                node.xpath_node("//meta[@itemprop='image']").try &.["content"].to_s ||
                node.xpath_node("//img[@src]").try &.["src"].to_s 

            # wrap($ => $filter($, $('article img[src]'), getSrc)),
            # wrap($ => $filter($, $('#content img[src]'), getSrc)),
            # wrap($ => $('img[alt*="author"]').attr('src')),
            # wrap($ => $('img[src]').attr('src'))
            image
        end

        def get_url(node : XML::Node)
            url = node.xpath_node("//meta[@property='og:url']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='twitter:url']").try &.["content"].to_s ||
                @site

            url
            # wrap($ => $('meta[property="og:url"]').attr('content')),
            # wrap($ => $('meta[name="twitter:url"]').attr('content')),
            # wrap($ => $('link[rel="canonical"]').attr('href')),
            # wrap($ => $('link[rel="alternate"][hreflang="x-default"]').attr('href')),
        end

        def get_author(node : XML::Node)
            author = node.xpath_node("//meta[@property='og:author']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='author']").try &.["content"].to_s ||
                node.xpath_node("//meta[@property='author']").try &.["content"].to_s ||
                node.xpath_node("//meta[@property='article:author']").try &.["content"].to_s

            author
     
            # wrap($ => $filter($, $('[itemprop*="author"] [itemprop="name"]'))),
            # wrap($ => $filter($, $('[itemprop*="author"]'))),
            # wrap($ => $filter($, $('[rel="author"]'))),
            # strict(wrap($ => $filter($, $('a[class*="author"]')))),
            # strict(wrap($ => $filter($, $('[class*="author"] a')))),
            # strict(wrap($ => $filter($, $('a[href*="/author/"]')))),
            # wrap($ => $filter($, $('a[class*="screenname"]'))),
            # strict(wrap($ => $filter($, $('[class*="author"]')))),
            # strict(wrap($ => $filter($, $('[class*="byline"]'))))
        end

        def get_description(node : XML::Node)
            description = node.xpath_node("//meta[@property='og:description']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='twitter:description']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='description']").try &.["content"].to_s ||
                node.xpath_node("//meta[@itemprop='description']").try &.["content"].to_s 
            
            description

            # wrap($ => $('#description').text()),
            # wrap($ => $filter($, $('[class*="content"] > p'))),
            # wrap($ => $filter($, $('[class*="content"] p')))
        end

        def get_title(node : XML::Node)
            title = node.xpath_node("//meta[@property='og:title']").try &.["content"].to_s ||
                node.xpath_node("//meta[@property='twitter:title']").try &.["content"].to_s ||
                node.xpath_node("//title").try &.["content"].to_s

            title

            # wrap($ => $('meta[property="og:title"]').attr('content')),
            # wrap($ => $('meta[name="twitter:title"]').attr('content')),
            # wrap($ => $('.post-title').text()),
            # wrap($ => $('.entry-title').text()),
            # wrap($ => $('h1[class*="title"] a').text()),
            # wrap($ => $('h1[class*="title"]').text()),
            # wrap($ => $filter($, $('title')))
        end

        def get_logo(node : XML::Node)
            logo = node.xpath_node("//meta[@property='og:logo']").try &.["content"].to_s ||
                node.xpath_node("//meta[@itemprop='logo']").try &.["content"].to_s ||
                node.xpath_node("//img[@itemprop='logo']").try &.["src"].to_s

            logo

            # wrap($ => $('meta[property="og:logo"]').attr('content')),
            # wrap($ => $('meta[itemprop="logo"]').attr('content')),
            # wrap($ => $('img[itemprop="logo"]').attr('src')),
        end

        def get_date(node : XML::Node)
            date = node.xpath_node("//meta[@property='article:published_time']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='dc.date']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='dc.date.issued']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='dc.date.created']").try &.["content"].to_s ||
                node.xpath_node("//meta[@name='date']").try &.["content"].to_s

            date
  
            # wrap($ => $('[itemprop="datePublished"]').attr('content')),
            # wrap($ => $('time[itemprop*="pubdate"]').attr('datetime')),
            # wrap($ => $('[property*="dc:date"]').attr('content')),
            # wrap($ => $('[property*="dc:created"]').attr('content')),
            # wrap($ => $('time[datetime][pubdate]').attr('datetime')),
            # wrap($ => $('meta[property="book:release_date"]').attr('content')),
            # wrap($ => $('time[datetime]').attr('datetime')),
            # wrap($ => $('[class*="byline"]').text()),
            # wrap($ => $('[class*="dateline"]').text()),
            # wrap($ => $('[id*="date"]').text()),
            # wrap($ => $('[class*="date"]').text()),
            # wrap($ => $('[id*="publish"]').text()),
            # wrap($ => $('[class*="publish"]').text()),
            # wrap($ => $('[id*="post-timestamp"]').text()),
            # wrap($ => $('[class*="post-timestamp"]').text()),
            # wrap($ => $('[id*="post-meta"]').text()),
            # wrap($ => $('[class*="post-meta"]').text()),
            # wrap($ => $('[id*="metadata"]').text()),
            # wrap($ => $('[class*="metadata"]').text()),
            # wrap($ => $('[id*="time"]').text()),
            # wrap($ => $('[class*="time"]').text())
        end

        def get_tags(node : XML::Node)
            tags = [] of String
            node.xpath_nodes("//meta[@property='article:tag']").try &.each do |tag|
                tags << tag.try &.["content"].to_s
            end

            tags
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
                return "#{yy.to_i} years ago"
            elsif yy == 1
                return "An year ago"
            elsif mo > 1 && mo < 13
                return "#{mo.to_i} months ago"
            elsif mo == 1
                return "A month ago"
            elsif dd > 1 && dd < 31
                return "#{dd.to_i} days ago"
            elsif dd == 1
                return "A day ago"
            elsif hh > 1 && hh < 25
                return "#{hh.to_i} hours ago"
            elsif hh == 1
                return "An hour ago"
            elsif mm > 5 && mm < 61
                return "#{mm.to_i} minutes ago"
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

    class AuthError < Exception
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