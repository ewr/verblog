module Verblog
  class Config
    class << self
      def user_model(model=nil)
        @user_model = model if model
        @user_model #|| DEFAULT_USER_MODEL
      end
      
      def asset_model(model=nil)
        @asset_model = model if model
        @asset_model #|| DEFAULT_ASSET_MODEL
      end
      
      def blog_path(path=nil)
        @blog_path = path if path
        @blog_path || nil
      end
    end
  end
end