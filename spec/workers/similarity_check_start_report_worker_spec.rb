require 'rails_helper'

describe SimilarityCheckStartReportWorker, type: :worker, sidekiq: :inline! do
  let(:paper) { create :paper, :version_with_file_type }
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
  subject(:perform) do
    SimilarityCheckStartReportWorker.perform_async(similarity_check.id)
  end

  before do
    stub_request(:get, stubbed_url).to_return(body: "turtles")
  end

  it "adds a document through the Ithenticate::Api" do
    expect(Ithenticate::Api).to(
      receive_message_chain(:new_from_tahi_env, :add_document)
        .and_return(fake_ithenticate_response)
    )
    perform
  end

  describe "successful ithenticate api calls" do
    before do
      allow(Ithenticate::Api).to(
        receive_message_chain(:new_from_tahi_env, :add_document)
          .and_return(fake_ithenticate_response)
      )
    end

    it "sets ithenticate_document_id on the SimilarityCheck record" do
      expect do
        perform
      end.to change { similarity_check.reload.ithenticate_document_id }
               .from(nil).to(fake_doc_id)
    end

    it "updates the AASM state of the SimilarityCheck record" do
      expect do
        perform
      end.to change { similarity_check.reload.state }
               .from("needs_upload").to("waiting_for_report")
    end
  end
end
