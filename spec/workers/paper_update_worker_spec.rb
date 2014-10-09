require 'spec_helper'

describe PaperUpdateWorker do
  let(:job) { IhatJob.create! job_id: "blah-blah",
                    paper: FactoryGirl.create(:paper) }
  subject(:worker) { PaperUpdateWorker.new }

  before do
    worker.job_id = job.job_id
  end

  describe "#perform" do
    before do
      json = { json: { body: "<h1>Hello</h1>" }.to_json }
      expect(Faraday).to receive(:get).with("#{ENV['IHAT_URL']}jobs/#{job.job_id}/download").and_return(json)
    end

    it "updates the paper" do
      worker.perform(job.job_id)
      expect(job.paper.reload.body).to eq("<h1>Hello</h1>")
    end
  end

  describe "#job" do
    it "finds the job" do
      expect(worker.job).to eq(job)
    end
  end

  describe "#paper_attributes" do
    it "requests the converted JSON from IHAT" do
      json = { json: { body: "<h1>Hello</h1>" }.to_json }
      expect(Faraday).to receive(:get).with("#{ENV['IHAT_URL']}jobs/#{job.job_id}/download").and_return(json)
      worker.paper_attributes
    end
  end
end
