$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "data_availability/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "data_availability"
  s.version     = DataAvailability::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of DataAvailability."
  s.description = "TODO: Description of DataAvailability."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.1"

  s.add_development_dependency "sqlite3"
end
