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

  describe "#sync_document!" do
    let(:similarity_check) { create :similarity_check, :waiting_for_report }
    before do
      allow_any_instance_of(Ithenticate::Api).to receive(:get_document)
                                                   .and_return(response_double)
    end

    context "the document's report is finished" do
      let(:report_score) { Faker::Number.number(2).to_i }
      let(:report_id) { Faker::Number.number(8).to_i }
      let(:response_double) do
        double("response", report_complete?: true, score: report_score, report_id: report_id)
      end

      it "updates the similarity check with the report score" do
        expect do
          similarity_check.sync_document!
        end.to change { similarity_check.score }.from(nil).to(report_score)
      end

      it "updates the similarity check with the report id" do
        expect do
          similarity_check.sync_document!
        end.to change { similarity_check.report_id }.from(nil).to(report_id)
      end

      it "sets the state of the similarity check" do
        expect do
          similarity_check.sync_document!
        end.to change { similarity_check.state }
                 .from("waiting_for_report")
                 .to("report_complete")
      end
    end
  end

  describe "#report_view_only_url" do
    context "the similarity check's report is not complete" do
      let(:similarity_check) { create :similarity_check, :waiting_for_report }

      it "raises an exception" do
        expect do
          similarity_check.report_view_only_url
        end.to raise_exception(SimilarityCheck::IncorrectState)
      end
    end

    context "the similarity check's report is complete" do
      let(:similarity_check) { create :similarity_check, :report_complete }
      let(:fake_url) { Faker::Internet.url }
      let(:response_double) do
        double(Ithenticate::ReportResponse, view_only_url: fake_url)
      end

      before do
        allow_any_instance_of(Ithenticate::Api).to(
          receive(:get_report).with(
            id: similarity_check.report_id
          ).and_return(response_double)
        )
      end

      it "returns an expiring url to the view_only version of the report" do
        expect(similarity_check.report_view_only_url).to eq fake_url
      end
    end
  end
end
