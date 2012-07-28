module Verblog
  class HomeController < ApplicationController
  
    def index
      @stories = Verblog::Story.published.paginate(
        :page => params[:page] || 1
      )
    
      if @current_user && @current_user.author?
        @drafts = Verblog::Story.find(:all,
          :conditions => ["status = ? or status = ?",Story::STATUS_DRAFT,Story::STATUS_PENDING],
          :order => "status desc, updated_at desc"
        )
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