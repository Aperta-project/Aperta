$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tahi/assign_team/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tahi-assign_team"
  s.version     = Tahi::AssignTeam::VERSION
  s.authors     = ["Rizwan Reza"]
  s.email       = ["rizwanreza@gmail.com"]
  s.homepage    = "http://github.com/tahi-project/tahi-assign_team"
  s.summary     = "This is a Tahi card that allows admins to assign Roles to Users from a journal workflow."
  s.description = "This is a Tahi card that allows admins to assign Roles to Users from a journal workflow."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.1"

  s.add_development_dependency "sqlite3"
end
