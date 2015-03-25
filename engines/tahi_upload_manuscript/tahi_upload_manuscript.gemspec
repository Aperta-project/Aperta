$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tahi_upload_manuscript/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tahi_upload_manuscript"
  s.version     = TahiUploadManuscript::VERSION
  s.authors     = ["Tahi"]
  s.email       = ["tahiprojectteam@plos.org"]
  s.homepage    = "http://github.com/tahi-project/tahi"
  s.summary     = "This is the upload manuscript card used in Tahi"
  s.description = "Allows a user to upload a manuscript document for the manuscript card"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.0"
end
