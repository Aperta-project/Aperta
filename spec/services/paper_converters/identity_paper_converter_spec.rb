require 'rails_helper'

describe PaperConverters::IdentityPaperConverter do
  let(:export_format) { 'pdf' }
  let(:paper) { create(:paper, :version_with_file_type) }
  let(:paper_version) { paper.latest_version }
  let(:converter) { described_class.new(paper_version, export_format) }

  it_behaves_like 'a redirecting paper converter'
end
