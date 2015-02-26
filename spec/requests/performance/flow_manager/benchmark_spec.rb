require 'rails_helper'
require 'benchmark'

TEST_NAME = "flow_manager"

shared_examples "a batch of papers" do |num_papers|
  describe UserFlowsController do
    let(:path) { BenchmarkSuite.path(TEST_NAME) }

    context "performance of papers" do
      before(:all) do
        @bench = BenchmarkSuite::FlowManager.new num_papers: num_papers
      end

      context "the user is a site admin" do
        before do
          post user_session_path, user: {:login => @bench.site_admin.email, :password => 'password'}

          GC.start
        end

        it "takes time" do
          result = RubyProf.profile do
            get '/user_flows.json'
          end
          printer = RubyProf::MultiPrinter.new(result)
          printer.print(:path => "doc/profiles", :profile => "profile_#{num_papers}_site_admin")

          p "User count: #{User.count}"
          p "Paper count: #{Paper.count}"
          p "Task count: #{Task.count}"
          time = Benchmark.realtime { get '/user_flows.json' }
          BenchmarkSuite::Results.new(test_name: TEST_NAME,
                                      duration: time,
                                      unit: :sec,
                                      title: "GET /user_flows.json, #{num_papers} papers, loading flows for journal with 100% of the papers").write
          expect(time).to be < 1.5
        end
      end

      context "when the user is an admin of big journal" do
        before do
          post user_session_path, user: {:login => @bench.big_admin.email, :password => 'password'}
        end

        it "takes time" do
          result = RubyProf.profile do
            get '/user_flows.json'
          end
          printer = RubyProf::MultiPrinter.new(result)
          printer.print(:path => "doc/profiles", :profile => "profile_#{num_papers}_big_admin")
          p "User count: #{User.count}"
          p "Paper count: #{Paper.count}"
          p "Task count: #{Task.count}"
          time = Benchmark.realtime { get '/user_flows.json' }
          BenchmarkSuite::Results.new(test_name: TEST_NAME,
                                      duration: time,
                                      unit: :sec,
                                      title: "GET /user_flows.json, #{num_papers} papers, loading flows for journal with 80% of the papers").write
          expect(time).to be < 1.5
        end
      end

      context "when the user is an admin of small journal" do
        before do
          post user_session_path, user: {:login => @bench.small_admin.email, :password => 'password'}
        end

        it "takes time" do
          result = RubyProf.profile do
            get '/user_flows.json'
          end
          printer = RubyProf::MultiPrinter.new(result)
          printer.print(:path => "doc/profiles", :profile => "profile_#{num_papers}_small_admin")

          p "User count: #{User.count}"
          p "Paper count: #{Paper.count}"
          p "Task count: #{Task.count}"
          time = Benchmark.realtime { get '/user_flows.json' }
          BenchmarkSuite::Results.new(test_name: TEST_NAME,
                                      duration: time,
                                      unit: :sec,
                                      title:  "GET /user_flows.json, #{num_papers} papers, loading flows for journal with 20% of the papers").write
          expect(time).to be < 1.5
        end
      end
    end
  end
end

describe "batch of papers", performance: true do
  before(:all) {
    VCR.turn_off! && WebMock.allow_net_connect!
    ActiveRecord::Base.logger = nil
  }

  after(:all)  {
    VCR.turn_on! && WebMock.disable_net_connect!
    BenchmarkSuite::Emailer.call(TEST_NAME)
  }

  it_should_behave_like "a batch of papers",    100
  it_should_behave_like "a batch of papers",  1_000
  it_should_behave_like "a batch of papers", 10_000

  it_should_behave_like "a batch of papers",    100
  it_should_behave_like "a batch of papers",  1_000
  it_should_behave_like "a batch of papers", 10_000

  it_should_behave_like "a batch of papers",    100
  it_should_behave_like "a batch of papers",  1_000
  it_should_behave_like "a batch of papers", 10_000
end
