require 'rails_helper'

describe SimilarityCheck, type: :model, redis: true do
  describe "the factory" do
    let(:similarity_check) { build :similarity_check }

    it "creates a valid record" do
      expect(similarity_check).to be_valid
    end
  end

  describe "#start_report_async" do
    let(:similarity_check) { create :similarity_check }
    subject(:start_report_async) { similarity_check.start_report_async }

    it "enqueues a SimilarityCheckStartReportWorker job" do
      expect do
        start_report_async
      end.to change { SimilarityCheckStartReportWorker.jobs.size }.by(1)
    end

    it "enqueues a job with the SimilarityCheck record id as an arg" do
      start_report_async
      args = SimilarityCheckStartReportWorker.jobs.first["args"]
      expect(similarity_check.id).to be_present
      expect(args).to eq [similarity_check.id]
    end
  end

  describe "#start_report!" do
    let(:similarity_check) { create :similarity_check }
    let(:paper) { create :paper, :version_with_file_type, :with_creator }
    let!(:similarity_check) { create :similarity_check, versioned_text: paper.latest_version }
    let(:stubbed_url) { paper.file.url }
    let(:fake_doc_id) { Faker::Number.number(8).to_i }
    let(:fake_ithenticate_response) do
      {
        "api_status" => 200,
        "uploaded" => [
          {
            "id" => fake_doc_id
          }
        ]
      }
    end

    subject(:start_report!) { similarity_check.start_report! }

    before do
      stub_request(:get, stubbed_url).to_return(body: "turtles")
      allow(Ithenticate::Api).to receive_message_chain(:new_from_tahi_env, :error?)
                                             .and_return(false)
    end

    it "adds a document through the Ithenticate::Api" do
      Sidekiq.redis { |redis| redis.set('ithenticate_folder', 1) }

      expect(Ithenticate::Api).to(
        receive_message_chain(:new_from_tahi_env, :add_document)
          .and_return(fake_ithenticate_response)
      )

      start_report!
    end

    describe "successful ithenticate api calls" do
      before do
        allow(Ithenticate::Api).to(
          receive_message_chain(:new_from_tahi_env, :add_document)
            .and_return(fake_ithenticate_response)
        )
      end

      it "sets ithenticate_document_id on the SimilarityCheck record" do
        Sidekiq.redis { |redis| redis.set('ithenticate_folder', 1) }
        expect do
          start_report!
        end.to change { similarity_check.ithenticate_document_id }
                 .from(nil).to(fake_doc_id)
      end

      it "updates the AASM state of the SimilarityCheck record" do
        Sidekiq.redis { |redis| redis.set('ithenticate_folder', 1) }
        expect do
          start_report!
        end.to change { similarity_check.state }
                 .from("needs_upload").to("waiting_for_report")
      end

      it "sets the similarity check's timeout_at" do
        Sidekiq.redis { |redis| redis.set('ithenticate_folder', 1) }
        expect(SimilarityCheck::TIMEOUT_INTERVAL).to be_present
        Timecop.freeze do |now|
          expect do
            start_report!
          end.to change { similarity_check.timeout_at }
                   .from(nil).to(now + SimilarityCheck::TIMEOUT_INTERVAL)
        end
      end

      it "sets document_s3_url" do
        Sidekiq.redis { |redis| redis.set('ithenticate_folder', 1) }
        expect do
          start_report!
        end.to change { similarity_check.document_s3_url }
                 .from(nil).to(stubbed_url)
      end
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
        double("response", error: nil, report_complete?: true, score: report_score, report_id: report_id, error?: false)
      end

      it "updates the similarity check's state to 'report_complete'" do
        expect do
          similarity_check.sync_document!
        end.to change { similarity_check.state }
                 .from("waiting_for_report")
                 .to("report_complete")
      end

      it "updates the similarity check with the report score" do
        expect do
          similarity_check.sync_document!
        end.to change { similarity_check.ithenticate_score }.from(nil).to(report_score)
      end

      it "updates the similarity check with the report id" do
        expect do
          similarity_check.sync_document!
        end.to change { similarity_check.ithenticate_report_id }.from(nil).to(report_id)
      end

      it "updates the similarity check's ithenticate_report_completed_at" do
        Timecop.freeze do |now|
          expect do
            similarity_check.sync_document!
          end.to change { similarity_check.ithenticate_report_completed_at }
                   .from(nil).to(now)
        end
      end

      it "sets the state of the similarity check" do
        expect do
          similarity_check.sync_document!
        end.to change { similarity_check.state }
                 .from("waiting_for_report")
                 .to("report_complete")
      end
    end

    context "the document's report is finished" do
      let(:similarity_check) { create :similarity_check, :waiting_for_report }
      let(:report_score) { Faker::Number.number(2).to_i }
      let(:report_id) { Faker::Number.number(8).to_i }
      let(:response_double) do
        double("response", report_complete?: false, error: nil, error?: false)
      end

      context "the system time is after the similarity check's timeout_at" do
        let(:timeout_offset) { 1.second }

        it "updates to similarity check's status to 'failed'" do
          Timecop.freeze(similarity_check.timeout_at + timeout_offset) do
            expect do
              similarity_check.sync_document!
            end.to raise_error('Report timed out after 10 minutes.')
            expect(similarity_check.state).to eq('failed')
          end
        end

        it "adds an error_message to similarity check" do
          Timecop.freeze(similarity_check.timeout_at + timeout_offset) do

            expect do
              similarity_check.sync_document!
            end.to raise_error('Report timed out after 10 minutes.')
            expect(similarity_check.error_message).to eq("Report timed out after 10 minutes.")
          end
        end
      end

      context "the system time is before the similarity check's timeout_at" do
        let(:timeout_offset) { -1.seconds }

        it "updates to similarity check's status to 'failed'" do
          Timecop.freeze(similarity_check.timeout_at + timeout_offset) do
            expect do
              similarity_check.sync_document!
            end.to_not change { similarity_check.state }
          end
        end
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
            id: similarity_check.ithenticate_report_id
          ).and_return(response_double)
        )
      end

      it "returns an expiring url to the view_only version of the report" do
        expect(similarity_check.report_view_only_url).to eq fake_url
      end
    end
  end
end
