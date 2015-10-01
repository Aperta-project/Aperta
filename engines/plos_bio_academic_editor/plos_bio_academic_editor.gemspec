$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "plos_bio_academic_editor/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "plos_bio_academic_editor"
  s.version     = PlosBioAcademicEditor::VERSION
  s.authors     = ["Anna Petry"]
  s.email       = ["hello@annapetry.com"]
  s.homepage    = "http://github.com/tahi-project/tahi"
  s.summary     = "PLOS Bio Invite Academic Editor Card"
  s.description = "PLOS Bio Invite Academic Editor Card"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.4"

  s.add_development_dependency "sqlite3"
end
