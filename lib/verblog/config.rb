module Verblog
  class Config
    @@config = {}
    class << self
      ["user_model","asset_model","blog_path","title","base_url","description"].each do |f|
        define_method f do |input=nil|
          @@config[f] = input if input
          @@config[f]
        end
      end
    end
  end
end