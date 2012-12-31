module Verblog
  class Engine < ::Rails::Engine
    isolate_namespace Verblog
    
    @@mpath = nil
    @@markdown = nil
    @@asset_model = nil
    
    #----------
    
    def markdown(text)
      return "" if !text || text.empty?
      
      if !@@markdown
        @@markdown = Verblog::Markdown.new()
      end
      
      @@markdown.render(text)
    end
    
    #----------
    
    def asset_model
      if !@@asset_model
        begin
          @@asset_model = Verblog::Config.asset_model.constantize
        rescue NameError
          raise "Invalid Asset Model: #{Verblog::Config.asset_model} produces NameError"
        end
      end
      
      @@asset_model
    end
    
    #----------
        
    def self.mounted_path
      if @@mpath
        return @@mpath.spec.to_s == '/' ? '' : @@mpath.spec.to_s
      end
      
      # -- find our path -- #
      
      route = Rails.application.routes.routes.detect do |route|
        route.app == self
      end
        
      if route
        @@mpath = route.path
      end

      return @@mpath.spec.to_s == '/' ? '' : @@mpath.spec.to_s
    end
    
  end
end
