$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "plos_authors/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "plos_authors"
  s.version     = PlosAuthors::VERSION
  s.authors     = ["Neo"]
  s.email       = ["tahi-project@neo.com"]
  s.homepage    = "http://www.tahi.com"
  s.summary     = %q(Custom authors for PLOS journal.)
  s.description = %q(Custom authors for PLOS journal.)
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]# add license info like "MIT-LICENSE"

  s.add_dependency "rails", "~> 4.2.0"
end

