xml.item do 
  xml.title story.title
  xml.guid story.remote_story_link
  xml.link story.remote_story_link
  xml.dc :creator, story.author_names

  descript = ''

  if story.assets.any?
    descript << <<-EOS
    #{story.assets.first.asset.wide.tag}

    <p><i>#{story.assets.first.caption} (#{story.assets.first.asset.owner})</i></p>
    EOS
  end

  descript << markdown(story.intro) + markdown(story.body)  

  xml.description descript
  xml.pubDate story.timestamp.rfc822 
  
end
