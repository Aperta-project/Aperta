require 'spec_helper'

describe IhatJobsController, :type => :controller do

  describe "PUT update" do
    subject(:job) { IhatJob.create! job_id: "blah-blah", paper: FactoryGirl.create(:paper) }

    it "returns http success" do
      put :update, id: job.job_id
      expect(response).to be_success
    end

    it "calls the PaperUpdateWorker" do
      expect(PaperUpdateWorker).to receive(:perform_async).with(job_id: job.job_id)
      put :update, id: job.job_id
    end
  end

end
