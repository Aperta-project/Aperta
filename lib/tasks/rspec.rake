require 'rspec/core/rake_task'
require 'tahi_plugin'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

RSpec::Core::RakeTask.module_eval do
  def pattern
    [@pattern] | TahiPlugin.plugins.map do |gem|
      File.join(gem.full_gem_path, 'spec', '**', '*_spec.rb')
    end
  end
end
