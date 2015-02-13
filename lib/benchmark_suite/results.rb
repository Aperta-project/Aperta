require 'csv'
require_relative 'path'

module BenchmarkSuite
  class Results
    attr_reader :test_name, :duration, :unit, :title

    def initialize(test_name:, duration:, unit:, title:)
      @test_name = test_name
      @duration = duration
      @unit = unit
      @title = title
    end

    def write
      File.open(path, "w") {} unless File.exist? path
      CSV.open(path, "a+") { |csv|
        csv << [Time.now.utc, current_sha, title, duration, unit]
      }
    end

    def path
      BenchmarkSuite.path(test_name)
    end

    def current_sha
      `git rev-parse HEAD`.strip
    end
  end
end
