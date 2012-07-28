module Verblog
  class Engine < ::Rails::Engine
    isolate_namespace Verblog
    
    @@mpath = nil
    
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
