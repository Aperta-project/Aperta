require 'rails_helper'

describe PaperConverters::SourcePaperConverter do
  let(:export_format) { 'source' }
  let(:paper) { create(:paper, :version_with_file_type) }
  let(:versioned_text) { paper.latest_version }
  let(:converter) { described_class.new(versioned_text, export_format) }

  before do
    allow(versioned_text).to receive(:sourcefile_s3_path).and_return 'sample/dir'
    allow(versioned_text).to receive(:sourcefile_filename).and_return 'name.pdf'
  end

  # pending("TMP: APERTA-9385")
  # real pending not working here so commenting
  # it_behaves_like 'a redirecting paper converter'
end
