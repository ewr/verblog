xml.rss('version' => '2.0', 'xmlns:dc' => "http://purl.org/dc/elements/1.1/") do
  xml.channel do 
    xml.title(Verblog::Config.title)
    xml.link(Verblog::Config.base_url)
    xml.description(Verblog::Config.description)
    
    xml << render(:partial => "story", :collection => @stories)
  end
end
