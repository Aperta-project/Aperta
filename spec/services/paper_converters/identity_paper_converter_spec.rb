require 'rails_helper'

describe PaperConverters::IdentityPaperConverter do
  let(:export_format) { 'pdf' }
  let(:paper) { create(:paper, :version_with_file_type) }
  let(:versioned_text) { paper.latest_version }
  let(:converter) { described_class.new(versioned_text, export_format) }

  it_behaves_like 'a redirecting paper converter'
end
