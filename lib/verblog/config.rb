module Verblog
  class Config
    @@config = {
      :user_model         => "::User",
      :asset_model        => "AssetHostCore::Asset",
      :blog_path          => "/",
      :title              => "Verblog",
      :base_url           => "",
      :description        => "",
      :markdown_assets    => true,
      :markdown_pygments  => true,
      :float_asset        => "home",
      :home_asset         => "home",
      :wide_asset         => "wide",
      :home_stories       => 5,
      :archive_stories    => 12
    }
    class << self
      @@config.keys.each do |f|
        define_method f do |input=nil|
          @@config[f] = input if input
          @@config[f]
        end
      end      
    end
  end
end