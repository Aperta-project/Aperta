$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "billing/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "billing"
  s.version     = Billing::VERSION
  s.authors     = ["David Trejo & Faun Winter"]
  s.email       = ["pair+david.trejo+faun.winter@neo.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Billing."
  s.description = "TODO: Description of Billing."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "sqlite3"
end
