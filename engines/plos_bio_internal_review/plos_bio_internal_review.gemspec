$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "plos_bio_internal_review/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "plos_bio_internal_review"
  s.version     = PlosBioInternalReview::VERSION
  s.authors     = ["Feifan Wang"]
  s.email       = ["feifanw@gmail.com"]
  s.homepage    = "https://github.com/Tahi-project/plos_bio_internal_review"
  s.summary     = "This gem contains internal review cards for PLOS Bio"
  s.description = "This gem contains internal review cards for PLOS Bio"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.1"

  s.add_development_dependency "sqlite3"
end
