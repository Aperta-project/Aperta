$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "upload_manuscript/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "upload_manuscript"
  s.version     = UploadManuscript::VERSION
  s.authors     = ["Tahi"]
  s.email       = ["tahiprojectteam@plos.org"]
  s.homepage    = "http://www.tahi.com"
  s.summary     = "Summary of UploadManuscript."
  s.description = "Description of UploadManuscript."
  # s.license     = ""

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.1.1"
end
