$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "plos_billing/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "plos_billing"
  s.version     = PlosBilling::VERSION
  s.authors     = ["Ryan Wold, Fei Wang, Rizwan Reza"]
  s.email       = ["pair+fei+ryan+riz@neo.com"]
  s.homepage    = "http://github.com/tahi-project/tahi"
  s.summary     = "Billing Card for PLOS"
  s.description = "Billing Card for PLOS"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "sqlite3"
end
