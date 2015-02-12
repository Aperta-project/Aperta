require 'rails_helper'
require 'benchmark'

describe UserFlowsController, performance: true do

  context "performance of 100 papers" do
    before(:all) do
      @bench = BenchmarkSuite::FlowManager.new num_papers: 100
    end

    context "the user is a site admin" do
      before do
        post user_session_path, user: {:login => @bench.site_admin.email, :password => 'password'}
      end

      it "accesses all default flows for all journals" do
        time = Benchmark.realtime {
         get '/user_flows.json'
        }
        BenchmarkSuite::Results.new(test_name: "site_admin_flow_manager",
                                    number_of_papers: 100,
                                    duration: time,
                                    unit: :sec,
                                    description: "Flow manager performance test with 100% papers").write
        expect(time).to be < 1.5
      end
    end

    context "when the user is an admin of big journal" do
      before do
        post user_session_path, user: {:login => @bench.big_admin.email, :password => 'password'}
      end

      it "accesses flows associated with their role" do
        time = Benchmark.realtime {
          get '/user_flows.json'
        }
        BenchmarkSuite::Results.new(test_name: "big_journal_admin_flow_manager",
                                    number_of_papers: 80,
                                    duration: time,
                                    unit: :sec,
                                    description: "Flow manager performance test with 80% papers").write
        expect(time).to be < 1.5
      end
    end

    context "when the user is an admin of small journal" do
      before do
        post user_session_path, user: {:login => @bench.small_admin.email, :password => 'password'}
      end

      it "accesses flows associated with their role" do
        time = Benchmark.realtime {
          get '/user_flows.json'
        }
        BenchmarkSuite::Results.new(test_name: "small_journal_admin_flow_manager",
                                    number_of_papers: 20,
                                    duration: time,
                                    unit: :sec,
                                    description: "Flow manager performance test with 20% papers").write
        expect(time).to be < 1.5
      end

    end
  end
end
