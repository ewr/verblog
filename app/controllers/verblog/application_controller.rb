module Verblog
  class ApplicationController < ::ApplicationController
    layout "verblog"
    helper Verblog::ApplicationHelper
    
    protected
    # Load a story from params[:story_id] or params[:id], populating @story.  For a non-live story, 
    # require the user to be an author
    def verblog_load_story
      @story = Story.find(params[:story_id] || params[:id])
    
      if @story.status == Story::STATUS_LIVE
        # they're fine
      else
        # make sure they're an author
        if !@current_user || !@current_user.author?
          redirect_to home_path and return
        else
          # ok
        end
      end
    rescue
      redirect_to home_path
    end
  
  
    # Require the author flag to be set 
    def verblog_only_author
      if !@current_user || !@current_user.author?
        redirect_to home_path and return
      end
    end
    
  end
end
