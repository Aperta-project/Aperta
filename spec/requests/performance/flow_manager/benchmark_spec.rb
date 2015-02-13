require 'rails_helper'
require 'benchmark'

TEST_NAME = "flow_manager"

shared_examples "a batch of papers" do |num_papers|
  describe UserFlowsController do
    let(:path) { BenchmarkSuite.path(TEST_NAME) }

    before(:all) { VCR.turn_off! && WebMock.allow_net_connect! }
    after(:all)  { VCR.turn_on! && WebMock.disable_net_connect! }

    context "performance of 100 papers" do
      before(:all) do
        @bench = BenchmarkSuite::FlowManager.new num_papers: num_papers
      end

      let(:time) { Benchmark.realtime { get '/user_flows.json' } }

      context "the user is a site admin" do
        before do
          post user_session_path, user: {:login => @bench.site_admin.email, :password => 'password'}
        end


        it "takes time" do
          BenchmarkSuite::Results.new(test_name: TEST_NAME,
                                      duration: time,
                                      unit: :sec,
                                      title: "#{num_papers}, 100%").write
          expect(time).to be < 1.5
        end
      end

      context "when the user is an admin of big journal" do
        before do
          post user_session_path, user: {:login => @bench.big_admin.email, :password => 'password'}
        end

        it "takes time" do
          BenchmarkSuite::Results.new(test_name: TEST_NAME,
                                      duration: time,
                                      unit: :sec,
                                      title: "#{num_papers}, 80%").write
          expect(time).to be < 1.5
        end
      end

      context "when the user is an admin of small journal" do
        before do
          post user_session_path, user: {:login => @bench.small_admin.email, :password => 'password'}
        end

        it "takes time" do
          BenchmarkSuite::Results.new(test_name: TEST_NAME,
                                      duration: time,
                                      unit: :sec,
                                      title: "#{num_papers}, 20%").write
          expect(time).to be < 1.5
        end
      end
    end
  end
end

describe "batch of papers", performance: true do
  it_should_behave_like "a batch of papers",    1
  it_should_behave_like "a batch of papers",  5
  it_should_behave_like "a batch of papers", 10

  after(:all) do
    BenchmarkSuite::Emailer.call(TEST_NAME)
  end
end
