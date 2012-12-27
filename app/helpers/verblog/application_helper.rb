module Verblog
  module ApplicationHelper
    def markdown(text)
      Verblog::Engine.markdown(text)
    end
    
    def _verblog_is_author
      current_user
      
    end
    
    #----------
    
    # Sorts authors, runs the given block on each of them, and joins them
    def render_authors(story,&blk)
      if story.authors.length == 1
        a = capture(story.authors.first,&blk)
        return a.html_safe
      else
        authors = story.sorted_authors
        
        [0,1].each do |i|
          authors[i] = authors[i].collect { |a| aa = capture(a,&blk).gsub(/(?:^\s+|\s+$)/,'') }
        end
        
        return Story.join_authors(authors).html_safe
      end
    end
    
    #----------
    
    def render_asset(content,context)
      # short circuit if it's obvious we're getting nowhere
      if !content || !content.respond_to?("assets") || !content.assets.any?
        return ''
      end
      
      # Register a content trigger on the assets collection
      register_content "#{content.obj_key}:assets"
      
      # look for a scheme on the content object
      scheme = (content.respond_to?(:asset_scheme) && content.asset_scheme) || "default"

      # set up our template precendence
      tmplt_opts = [
        "#{context}/#{scheme}",
        "#{context}/default",
        "default/#{scheme}",
        "default/default"
      ]
      
      partial = tmplt_opts.detect { |t| self.lookup_context.exists?(t,["verblog/shared/assets"],true) }

      render :partial => "verblog/shared/assets/#{partial}", :object => content.assets, :as => :assets, :locals => { :content => content }
    end
    
    #----------

  	# Vary the date format depending on how long ago the date is.
  	# Today: Just give a time
  	# Yesterday: Day of the week plus a time
  	# Last five days: Day of the week
  	# Any further back: Date

  	def smart_date (time)
  	  now = Date.today()
  	  date = time.to_date

      key = ""

  	  if now === date
  	    # today
  	    key = "%I:%M %p"
  	  elsif (now - 1) === date
  	    # yesterday
  	    key = "Yesterday, %I:%M %p"
  	  elsif (date >= (now - 5)) && (date < now)
  	    # within the last five days
  	    key = "%A"
  	  else
  	    # older (or future, but that shouldn't happen)
  	    key = "%B %d, %Y"
  	  end  

  	  return time.strftime(key)
  	end

  	#----------

  	def smart_days_ago (time)
  	  now = Date.today
  	  date = time.to_date

  	  if now === date
  	    # today
  	    return "Today"
  	  elsif ( now - 1) === date
  	    return "Yesterday"
  	  elsif (date >= (now - 6)) && (date < now)
        return time.strftime("%A")
  	  else 
  	    return time.strftime("%B %d, %Y")
  	  end
  	end

  	#----------

  	# Cut text down to the length set by Story::CLIPPING_LENGTH or the given 
  	# length.
  	def clipping(text,clips = Story::CLIPPING_LENGTH)
  		if ( text.length > ( clips + 3 ) ) 
  			match = /^(.{#{clips}}\w*)\W/m.match(text)

  			if ( match ) 
  			  text = "#{match[1]}..."
  			else 
          # we're already set
  			end
  		else 
  			# just let it go
  		end

  		return text
  	end
  	
  	#----------
  	
  	def fmt_url (url)
  		return if (!url)

  		formatted = ''
  		if url =~ /^http/
  			formatted = url
  		else
  			formatted = 'http://' + url
  		end

  		return formatted
  	end

  	#----------

  	def chop_url(url,l = 80)
  	  if url.length <= l
  	    return url
      else
        return url[0..l/2-2] + "..." + url[-1*(l/2-2)..-1]
      end
    end

  	#----------

  	def chop_at_word (title,l = 19)
  		stitle = title

  		if ( title.length > l ) 
  			stitle = /^(.{#{l}}\w*)\W/.match(title)

  			if ( stitle ) 
  			  stitle = "#{stitle[1]}..."
  			else 
  				stitle = title
  			end
  		else 
  			# just let it go
  		end

  		return stitle
  	end


  	#----------

  	def verblog_recent_stories
  	  Story.find(
  	    :all,
  	    :conditions => ["status = ?",Story::STATUS_LIVE],
  	    :order => "timestamp desc",
  	    :limit => 10
  	  )
    end

  	#----------

  	def verblog_recent_comments
  	  Comment.find(
    			:all,
    			:order => "comments.created_at desc",
    			:limit => 10,
    			:include => [:story]
    	)
    end
    
    def verblog_on_this_date
      today = Date.today()

      # NOTE: Initial year is set manually
  		iyear = 1998;

      on_date = []

  		while ( today.year >= iyear ) 
  			tomorrow = today + 1

  			ypost = Story.published.find(
  				:all,
  				:order => "timestamp desc",
  				:conditions => [
  				  'timestamp > ? and timestamp < ?',
  				  today,tomorrow
  				]
  			)

  			on_date << [ today.year , ypost ]

  			today = today << 12
  		end		
		
  		return on_date
		end
  end
end
