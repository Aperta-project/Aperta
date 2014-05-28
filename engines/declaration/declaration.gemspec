$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "declaration/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "declaration"
  s.version     = Declaration::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Declaration."
  s.description = "TODO: Description of Declaration."
  # s.license     = ""

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.1.1"
end
