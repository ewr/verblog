module Verblog
  class StoryAsset < ActiveRecord::Base  
    belongs_to :story
    belongs_to :asset, :class_name => Verblog::Config.asset_model
  
    validates :story, :presence => true
    validates :asset_id, :presence => true
    validates :position, :presence => true
  
    #----------
  
    # Fetch asset JSON and then merge in our caption and position
    def as_json(options)
      # grab asset as_json then merge in our values
      self.asset.as_json(options).merge({"caption" => self.caption, "ORDER" => self.position})
    end
  
  end
end