$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "declaration/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "declaration"
  s.version     = Declaration::VERSION
  s.authors     = ["Neo"]
  s.email       = ["tahi-project@neo.com"]
  s.homepage    = "http://www.tahi.com"
  s.summary     = "Declaration task"
  s.description = "Declaration task"
  s.license     = "TBD"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.1.1"
end
