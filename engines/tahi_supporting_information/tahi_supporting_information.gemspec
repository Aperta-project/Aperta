$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tahi_supporting_information/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tahi_supporting_information"
  s.version     = TahiSupportingInformation::VERSION
  s.authors     = ["Tahi"]
  s.email       = ["tahiprojectteam@plos.org"]
  s.homepage    = "http://github.com/tahi-project/tahi"
  s.summary     = "Allows users to upload supporting materials for tasks"
  s.description = "This is a generic version of uploading materials to support figure tasks"
  # s.license     = "Copyright"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile"]

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "rspec-rails"
end
