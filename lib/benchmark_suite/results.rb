require 'csv'

# TODO: make sure to close the file
module BenchmarkSuite
  class Results
    attr_reader :csv_file, :test_name, :number_of_papers, :duration, :unit, :description

    PERFORMANCE_PATH = 'doc/performance_results'

    def initialize(test_name:, number_of_papers:, duration:, unit:, description:)
      @test_name = test_name
      @number_of_papers = number_of_papers
      @duration = duration
      @unit = unit
      @description = description
    end

    def write
      CSV.open(path, "a+") { |csv|
        csv << [Time.now.utc, current_sha, number_of_papers, description, duration, unit]
      }
    end

    def path
      "#{PERFORMANCE_PATH}/#{test_name}.csv"
    end

    def current_sha
      `git rev-parse HEAD`.strip
    end
  end
end
