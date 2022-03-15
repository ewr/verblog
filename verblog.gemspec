$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "verblog/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "verblog"
  s.version     = Verblog::VERSION
  s.authors     = ["Eric Richardson"]
  s.email       = ["e@ericrichardson.com"]
  s.homepage    = "http://github.com/ewr/verblog"
  s.summary     = "Rails blog engine integrated with AssetHost"
  s.description = "Rails blog engine integrated with AssetHost"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.6"
  s.add_dependency "kaminari"
  s.add_dependency 'haml'
  s.add_dependency "redcarpet"

  s.add_development_dependency "sqlite3"
end
