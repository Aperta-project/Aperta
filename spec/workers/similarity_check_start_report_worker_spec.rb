require 'rails_helper'

describe SimilarityCheckStartReportWorker, type: :worker, sidekiq: :inline! do
  let(:paper) { create :paper, :version_with_file_type }
  let!(:similarity_check) { create :similarity_check, versioned_text: paper.latest_version }

  it "works", vcr: { cassette_name: 'ithenticate' } do
    allow(Faraday).to receive_message_chain(:get, :body)
    SimilarityCheckStartReportWorker.perform_async(similarity_check.id)
  end
end
