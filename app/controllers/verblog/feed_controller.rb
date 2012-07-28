module Verblog
  class FeedController < ApplicationController
    def feed
      @stories = Story.find(:all,
  	    :conditions => ['status = ?',Story::STATUS_LIVE],
  	    :order => "timestamp desc",
  	    :limit => 8
  	  )	  
	  
  	  render :formats => :xml, :layout => false
    end
  end
end