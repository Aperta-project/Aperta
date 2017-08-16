module BenchmarkSuite
  PERFORMANCE_PATH = 'doc'.freeze

  def self.path(test_name)
    "#{PERFORMANCE_PATH}/#{test_name}.csv"
  end
end
