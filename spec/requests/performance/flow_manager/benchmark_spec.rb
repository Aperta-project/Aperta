require 'rails_helper'
require 'benchmark'

TEST_NAME = "flow_manager"

describe UserFlowsController, performance: true do
  let(:path) { BenchmarkSuite.path(TEST_NAME) }

  context "performance of 100 papers" do
    before(:all) do
      @num_papers = 100
      @bench = BenchmarkSuite::FlowManager.new num_papers: @num_papers
    end

    after(:all) do
      BenchmarkSuite::Emailer.call(TEST_NAME)
    end

    context "the user is a site admin" do
      before do
        post user_session_path, user: {:login => @bench.site_admin.email, :password => 'password'}
      end

      it "#{@num_papers}, 100%" do |example|
        time = Benchmark.realtime {
          get '/user_flows.json'
        }
        BenchmarkSuite::Results.new(test_name: TEST_NAME,
                                    duration: time,
                                    unit: :sec,
                                    title: example.description).write
        expect(time).to be < 1.5
      end
    end

    context "when the user is an admin of big journal" do
      before do
        post user_session_path, user: {:login => @bench.big_admin.email, :password => 'password'}
      end

      it "#{@num_papers}, 80%" do |example|
        time = Benchmark.realtime {
          get '/user_flows.json'
        }
        BenchmarkSuite::Results.new(test_name: TEST_NAME,
                                    duration: time,
                                    unit: :sec,
                                    title: example.description).write
        expect(time).to be < 1.5
      end
    end

    context "when the user is an admin of small journal" do
      before do
        post user_session_path, user: {:login => @bench.small_admin.email, :password => 'password'}
      end

      it "#{@num_papers}, 20%" do |example|
        time = Benchmark.realtime {
          get '/user_flows.json'
        }
        BenchmarkSuite::Results.new(test_name: TEST_NAME,
                                    duration: time,
                                    unit: :sec,
                                    title: example.description).write
        expect(time).to be < 1.5
      end
    end
  end


  context "performance of 1_000 papers" do
    before(:all) do
      @num_papers = 1_000 # change
      @bench = BenchmarkSuite::FlowManager.new num_papers: @num_papers
    end

    after(:all) do
      BenchmarkSuite::Emailer.call(TEST_NAME)
    end

    context "the user is a site admin" do
      before do
        post user_session_path, user: {:login => @bench.site_admin.email, :password => 'password'}
      end

      it "#{@num_papers}, 100%" do |example|
        time = Benchmark.realtime {
          get '/user_flows.json'
        }
        BenchmarkSuite::Results.new(test_name: TEST_NAME,
                                    duration: time,
                                    unit: :sec,
                                    title: example.description).write
        expect(time).to be < 1.5
      end
    end

    context "when the user is an admin of big journal" do
      before do
        post user_session_path, user: {:login => @bench.big_admin.email, :password => 'password'}
      end

      it "#{@num_papers}, 80%" do |example|
        time = Benchmark.realtime {
          get '/user_flows.json'
        }
        BenchmarkSuite::Results.new(test_name: TEST_NAME,
                                    duration: time,
                                    unit: :sec,
                                    title: example.description).write
        expect(time).to be < 1.5
      end
    end

    context "when the user is an admin of small journal" do
      before do
        post user_session_path, user: {:login => @bench.small_admin.email, :password => 'password'}
      end

      it "#{@num_papers}, 20%" do |example|
        time = Benchmark.realtime {
          get '/user_flows.json'
        }
        BenchmarkSuite::Results.new(test_name: TEST_NAME,
                                    duration: time,
                                    unit: :sec,
                                    title: example.description).write
        expect(time).to be < 1.5
      end
    end
  end

  context "performance of 10_000 papers" do
    before(:all) do
      @num_papers = 10_000
      @bench = BenchmarkSuite::FlowManager.new num_papers: @num_papers
    end

    after(:all) do
      BenchmarkSuite::Emailer.call(TEST_NAME)
    end

    context "the user is a site admin" do
      before do
        post user_session_path, user: {:login => @bench.site_admin.email, :password => 'password'}
      end

      it "#{@num_papers}, 100%" do |example|
        time = Benchmark.realtime {
          get '/user_flows.json'
        }
        BenchmarkSuite::Results.new(test_name: TEST_NAME,
                                    duration: time,
                                    unit: :sec,
                                    title: example.description).write
        expect(time).to be < 1.5
      end
    end

    context "when the user is an admin of big journal" do
      before do
        post user_session_path, user: {:login => @bench.big_admin.email, :password => 'password'}
      end

      it "#{@num_papers}, 80%" do |example|
        time = Benchmark.realtime {
          get '/user_flows.json'
        }
        BenchmarkSuite::Results.new(test_name: TEST_NAME,
                                    duration: time,
                                    unit: :sec,
                                    title: example.description).write
        expect(time).to be < 1.5
      end
    end

    context "when the user is an admin of small journal" do
      before do
        post user_session_path, user: {:login => @bench.small_admin.email, :password => 'password'}
      end

      it "#{@num_papers}, 20%" do |example|
        time = Benchmark.realtime {
          get '/user_flows.json'
        }
        BenchmarkSuite::Results.new(test_name: TEST_NAME,
                                    duration: time,
                                    unit: :sec,
                                    title: example.description).write
        expect(time).to be < 1.5
      end
    end
  end

end
