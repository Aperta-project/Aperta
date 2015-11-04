$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "plos_bio_tech_check/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "plos_bio_tech_check"
  s.version     = PlosBioTechCheck::VERSION
  s.authors     = ["Rizwan Reza"]
  s.email       = ["rizwanreza@gmail.com"]
  s.homepage    = "https://github.com/Tahi-project/plos_bio_tech_check"
  s.summary     = "This gem contains Tech Check and Changes For Author cards"
  s.description = "This gem contains Tech Check and Changes For Author cards"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "sqlite3"
end
