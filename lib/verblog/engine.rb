module Verblog
  class Engine < ::Rails::Engine
    isolate_namespace Verblog
    
    @@mpath = nil
    @@markdown = nil
    
    #----------
    
    def markdown(text)
      return "" if text.empty?
      
      if !@@markdown
        @@markdown = Verblog::Config.markdown.call()
      end
      
      @@markdown.render(text)
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
