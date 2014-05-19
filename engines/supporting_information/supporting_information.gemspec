$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "supporting_information/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "supporting_information"
  s.version     = SupportingInformation::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of SupportingInformation."
  s.description = "TODO: Description of SupportingInformation."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1.1"
  s.add_dependency "pry-rails"
  s.add_dependency "pry"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "pry"
end
