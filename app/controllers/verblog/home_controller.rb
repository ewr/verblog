module Verblog
  class HomeController < ApplicationController
  
    def index
      @stories = Verblog::Story.published.paginate(
        :page => params[:page] || 1
      )
    
      if _verblog_is_author
        @drafts = Verblog::Story.where(:status => [Verblog::Story::STATUS_DRAFT,Verblog::Story::STATUS_PENDING]).order("status desc, updated_at desc")
      end
    end
  
    #----------
    
    #----------
  
    def remap_id
      s = Story.find_by_old_id(params[:id])
    
      redirect_to s.story_link
    
    rescue
      redirect_to home_path
    end
  end
end