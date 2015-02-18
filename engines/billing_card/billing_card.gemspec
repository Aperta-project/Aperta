$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "billing_card/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "billing_card"
  s.version     = BillingCard::VERSION
  s.authors     = ["Anna Petry & Ryan Wold"]
  s.email       = ["pair+anna.petry+ryan.wold@neo.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of BillingCard."
  s.description = "TODO: Description of BillingCard."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "sqlite3"
end
