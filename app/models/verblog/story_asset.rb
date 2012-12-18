module Verblog
  class StoryAsset < ActiveRecord::Base  
    belongs_to :story
    belongs_to :asset, :class_name => Verblog::Config.asset_model
  
    validates :story, :presence => true
    validates :asset_id, :presence => true
    validates :position, :presence => true
    
    before_save :expire_content_caches
  
    #----------
  
    # Fetch asset JSON and then merge in our caption and position
    def as_json(options)
      # grab asset as_json then merge in our values
      self.asset.as_json(options).merge({"caption" => self.caption, "ORDER" => self.position})
    end
    
    def obj_key
      "story_asset:#{self.id}"
    end
    
    #----------
    
    protected
    def expire_content_caches
      if Rails.cache.is_a?(ActiveSupport::Cache::RedisContentStore)
        Rails.cache.expire_obj(self)
      end
    end
  
  end
end