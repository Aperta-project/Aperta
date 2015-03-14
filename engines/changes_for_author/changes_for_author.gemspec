$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "changes_for_author/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "changes_for_author"
  s.version     = ChangesForAuthor::VERSION
  s.authors     = ["Rizwan Reza"]
  s.email       = ["rizwanreza@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ChangesForAuthor."
  s.description = "TODO: Description of ChangesForAuthor."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "sqlite3"
end
