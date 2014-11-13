require 'spec_helper'

describe PaperUpdateWorker do
  let(:job) { IhatJob.create! job_id: "blah-blah",
                    paper: FactoryGirl.create(:paper) }
  subject(:worker) { PaperUpdateWorker.new }

  before do
    worker.job_id = job.job_id
  end

  describe "#perform" do
    let(:stubbed_url) { "s3_url_example" }
    let(:turtles_fixture) { File.open(Rails.root.join('spec', 'fixtures', 'turtles.epub'), 'r').read }

    before do
      job_response = double(:job_response)
      allow(job_response).to receive(:body).and_return({ jobs: { url: stubbed_url } }.to_json)
      expect(Faraday).to receive(:get).with("#{ENV['IHAT_URL']}/jobs/#{job.job_id}").and_return job_response

      epub_response = double(:epub)
      allow(epub_response).to receive(:body).and_return(turtles_fixture)
      expect(Faraday).to receive(:get).with(stubbed_url).and_return(epub_response)
    end

    it "updates the paper" do
      worker.perform(job.job_id)
      expect(job.paper.reload.body).to eq("<p>This is a stubbed turtle file</p>")
    end
  end

  describe "#job" do
    it "finds the job" do
      expect(worker.job).to eq(job)
    end
  end
end
