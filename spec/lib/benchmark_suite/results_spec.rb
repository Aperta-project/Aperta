require 'spec_helper'
require 'timecop'
require 'pry'
require_relative '../../../lib/benchmark_suite/results'

describe BenchmarkSuite::Results do
  before(:all) do
    Timecop.freeze(Time.local(1990))
  end

  let(:benchmark_suite) {
    BenchmarkSuite::Results.new(test_name: 'blah',
                                title: 'blah blah blah',
                                duration: 4.2,
                                unit: :sec)
  }

  describe "#write" do
    it "writes the measurement in a CSV file" do
      expect(benchmark_suite).to receive(:current_sha).and_return('supercool-sha')

      benchmark_suite.write

      last_row = File.readlines(benchmark_suite.path).last
      expect(last_row).to match(/,supercool-sha,blah blah blah,4.2,sec/)
    end
  end

  after(:all) do
    Timecop.return
  end
end
