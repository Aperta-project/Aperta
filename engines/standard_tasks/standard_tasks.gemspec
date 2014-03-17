$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "standard_tasks/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "standard_tasks"
  s.version     = StandardTasks::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of StandardTasks."
  s.description = "TODO: Description of StandardTasks."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.0.rc1"

  s.add_development_dependency "sqlite3"
end
