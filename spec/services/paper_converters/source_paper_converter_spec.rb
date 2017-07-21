require 'rails_helper'

describe PaperConverters::SourcePaperConverter do
  let(:export_format) { 'source' }
  let(:paper) { create(:paper, :version_with_file_type) }
  let(:paper_version) { paper.latest_version }
  let(:converter) { described_class.new(paper_version, export_format) }

  before do
    allow(paper_version).to receive(:sourcefile_s3_path).and_return 'sample/dir'
    allow(paper_version).to receive(:sourcefile_filename).and_return 'name.pdf'
  end

  it_behaves_like 'a redirecting paper converter'
end
