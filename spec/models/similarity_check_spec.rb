require 'rails_helper'

describe SimilarityCheck, type: :model do
  describe "#create" do
    let(:versioned_text) { create :versioned_text }
    let(:do_create) { SimilarityCheck.create!(versioned_text: versioned_text) }

    it "enqueues a SimilarityCheckStartReportWorker job" do
      expect do
        do_create
      end.to change { SimilarityCheckStartReportWorker.jobs.size }.by(1)
    end

    it "enqueues a job with the SimilarityCheck record id as an arg" do
      similarity_report = do_create
      args = SimilarityCheckStartReportWorker.jobs.first["args"]
      expect(similarity_report.id).to be_present
      expect(args).to eq [similarity_report.id]
    end
  end
end
