xml.instruct!
xml.rss "version" => "0.91" do
  xml.channel do
    xml.title @feed_title || AppConfig.site_name
    xml.link @feed_link unless @feed_link.blank?
    xml.description @feed_description || ""
    xml.pubDate CGI.rfc1123_date(@commands.first.created_at) unless @commands.blank?
    
    @commands.each do |command|
      xml.item do
        xml.title h(command.name)
        xml.link man_url(:args => command.name)
                        
        xml.description do |description| 
          description.cdata! "<pre>#{command.description}</pre>"
        end
        xml.pubDate CGI.rfc1123_date(command.created_at)
      end
    end
  end
end
