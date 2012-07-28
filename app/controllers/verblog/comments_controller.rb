module Verblog
  class CommentsController < ApplicationController
    before_filter :verblog_only_author, :only => [:destroy,:edit,:update]
  
    before_filter :verblog_load_story
  
    #cache_sweeper :comment_sweeper
  
    def index
    
    end
  
    #----------
  
    def code
  		render :text => @story.comment_codes.create.code
    end

    #----------
  
    def create
      c = @story.comments.build(params[:comment])
    		
  		if (@current_user)
  			c.user = @current_user
  		end

  		# -- check the comment code -- #

  		checks = false
  		if ( icode = params[:commentcode] ) 
  			# look up this code
  			code = @story.comment_codes.find_by_code(icode);

        if code
  				checks = true
  				# now that it's been used, trash it
  				code.destroy()
  			end
  		end

  		if !checks
  			render :text => "Comment code is invalid.  Please try again."
  			return
  		else 
  			if c.save()
  				@count = c.story.comments.length

  				render(:update) do |page|
  					page[:compose].replace_html :partial => 'posted'
  					page.insert_html :bottom, 'commentblock', :partial => 'verblog/shared/comment/view', :object => c
  					page << "Element.addClassName($('c"+c.id.to_s+"'),'new');"
  					page << "Element.scrollTo($('c"+c.id.to_s+"'));"
					
  					if c.user && c.user.fb_uid					  
  					  # assemble feed form data
  					  cdata = {
  					    :title => c.story.title,
  					    :url => c.link,
  					    :story_url => c.story.remote_story_link,
  					    :excerpt => clipping(strip_tags(markdown(c.comment)),120),
  					    :comment => strip_tags(markdown(c.comment))
  					  }
					  
  					  page << "fb.popCommentFeedForm(#{cdata.to_json})"
  				  end
  				end
  			else
  				render(:update) do |page|
  					page[:compose_error].replace_html "Error posting comment: " + c.errors.full_messages.join(" | ")
  					page[:compose_error].show
  				end
  			end
  		end
		
    end
  
    #----------
  
    def show
    
    end
  
    #----------
  
  end
end
