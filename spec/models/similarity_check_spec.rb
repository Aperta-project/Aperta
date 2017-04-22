require 'rails_helper'

describe SimilarityCheck, type: :model do
  describe "the factory" do
    let(:similarity_check) { build :similarity_check }

    it "creates a valid record" do
      expect(similarity_check).to be_valid
    end
  end

  describe "#start_report" do
    let(:similarity_check) { create :similarity_check }
    subject(:start_report) { similarity_check.start_report }

    it "enqueues a SimilarityCheckStartReportWorker job" do
      expect do
        start_report
      end.to change { SimilarityCheckStartReportWorker.jobs.size }.by(1)
    end

    it "enqueues a job with the SimilarityCheck record id as an arg" do
      start_report
      args = SimilarityCheckStartReportWorker.jobs.first["args"]
      expect(similarity_check.id).to be_present
      expect(args).to eq [similarity_check.id]
    end
  end
end
