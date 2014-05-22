$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "upload_manuscript/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "upload_manuscript"
  s.version     = UploadManuscript::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of UploadManuscript."
  s.description = "TODO: Description of UploadManuscript."
  # s.license     = ""

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.1.1"
end
