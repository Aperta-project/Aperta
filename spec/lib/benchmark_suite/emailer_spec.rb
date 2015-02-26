require 'spec_helper'
require_relative '../../../lib/benchmark_suite/emailer'

require 'timecop'
require 'pry'
require 'dotenv'


describe BenchmarkSuite::Emailer do
  describe ".call" do
    before(:all) { Dotenv.overload(".env.test") }

    let(:benchmark_double) { double(:benchmark_flow_manager,
                                    test_name: "flow manager dumb test",
                                    path: 'spec/fixtures/yeti.jpg') }


    it "makes a POST request to Mailgun's endpoint with the CSV files" do
      # Comment this and provide correct API key in `.env.test`
      # to test actual email sends
      expect(RestClient).to receive(:post).with('https://api:YOUR_API_KEY@api.mailgun.net/v2/sandboxcd344b254a6446dd860757fcc93d7546.mailgun.org/messages',
                                                from: /Mailgun Sandbox*/,
                                                to: "Mike Mazur <mike@neo.com>",
                                                subject: "Performance test results for: #{benchmark_double.test_name}",
                                                text: "Attached",
                                                multipart: true,
                                                attachment: kind_of(File)).and_return('something')
      BenchmarkSuite::Emailer.call(benchmark_double)
    end
  end
end
