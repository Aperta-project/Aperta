require 'simplecov'
require 'codeclimate-test-reporter'

namespace :coverage do
  desc "Notify Code Climate of test coverage"
  task report: :environment do

    CodeClimate::TestReporter::Formatter.new.format(SimpleCov.result)
  end
end
