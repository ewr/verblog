module Verblog
  class StoryAuthor < ActiveRecord::Base
    belongs_to :story
    belongs_to :user, :class_name => Verblog::Config.user_model
    
    attr_accessible :story, :user, :is_primary
    
    scope :primary, where(:is_primary => true)
    scope :secondary, where(:is_primary => false)
    
    def name
      if self.user
        self.user.name
      else
        self.name
      end
    end  
      
  end
end