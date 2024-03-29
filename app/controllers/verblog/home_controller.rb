module Verblog
  class HomeController < ApplicationController
  
    def index
      @stories = Verblog::Story.published.page(params[:page]||1).per(Verblog::Config.home_stories)
    
      @drafts = Verblog::Story.where(:status => [Verblog::Story::STATUS_DRAFT,Verblog::Story::STATUS_PENDING]).order("status desc, updated_at desc")
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