require 'rails_helper'

describe SimilarityCheck, type: :model do
  describe "the factory" do
    let(:similarity_check) { build :similarity_check }

    it "creates a valid record" do
      expect(similarity_check).to be_valid
    end
  end

  describe "#create" do
    let(:do_create) { create :similarity_check }

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
