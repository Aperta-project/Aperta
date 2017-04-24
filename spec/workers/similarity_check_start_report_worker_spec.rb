require 'rails_helper'

describe SimilarityCheckStartReportWorker, type: :worker, sidekiq: :inline! do
  let(:paper) { create :paper, :version_with_file_type }
  let!(:similarity_check) { create :similarity_check, versioned_text: paper.latest_version }
  let(:stubbed_url) { paper.file.url }

  before do
    stub_request(:get, stubbed_url).to_return(body: "turtles")
  end

  it "works" do
    SimilarityCheckStartReportWorker.perform_async(similarity_check.id)
  end
end
