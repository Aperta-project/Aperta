$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "standard_tasks/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "standard_tasks"
  s.version     = StandardTasks::VERSION
  s.authors     = ["Neo"]
  s.email       = ["tahi-project@neo.com"]
  s.homepage    = "http://www.tahi.com"
  s.summary     = %q(A modular set of Task models for assembling workflows)
  s.description = %q(Provides a set of modular Tasks that can be easily combined into different workflows.)
  s.license     = "TBD"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]# add license info like "MIT-LICENSE"
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "sqlite3"

  # Spec dependencies
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'
end
