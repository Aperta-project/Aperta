$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "supporting_information/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "supporting_information"
  s.version     = SupportingInformation::VERSION
  s.authors     = ["Tahi"]
  s.email       = ["tahiprojectteam@plos.org"]
  s.homepage    = "tahi.com"
  s.summary     = "TODO: Summary of SupportingInformation."
  s.description = "TODO: Description of SupportingInformation."
  # s.license     = "Copyright"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile"]

  s.add_dependency "rails", "~> 4.1.1"

  s.add_development_dependency "rspec-rails"
end
