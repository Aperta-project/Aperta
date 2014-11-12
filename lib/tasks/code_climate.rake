require 'simplecov'
require 'codeclimate-test-reporter'

namespace :code_climate do
  namespace :coverage do

    desc "Notify Code Climate of test coverage"
    task :report do
      CodeClimate::TestReporter::Formatter.new.format(SimpleCov.result)
    end

  end
end
