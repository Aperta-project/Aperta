require 'rails_helper'

describe PaperConverters::PdfWithAttachmentsPaperConverter do
  let(:export_format) { 'pdf' }
  let(:paper) { create(:paper, :version_with_file_type) }
  let!(:figures) { create_list(:figure, 2, owner: paper).tap { paper.reload } }
  let(:versioned_text) { paper.latest_version }
  let(:converter) { PaperConverters::PdfWithAttachmentsPaperConverter.new(versioned_text, export_format) }

  it_behaves_like "a synchronous paper converter"

  # More coverage in pdf_with_attachments.html.erb_spec.rb
  describe "#create_figures_html" do
    it "creates an html document that contains all of the figures" do
      html = converter.create_attachments_html
      expect(html).to match(/img/)
    end
  end

  describe "#output_filename" do
    subject { converter.output_filename }
    it { is_expected.to match(/.+ with attachments\.pdf/) }
  end

  describe "#parsed_uploaded_pdf" do
    subject { converter.parsed_uploaded_pdf }
    before do
      allow(converter).to receive(:uploaded_pdf_data) do
        File.read(Rails.root.join('spec/fixtures/about_turtles.pdf'))
      end
    end

    it { is_expected.to be_an_instance_of CombinePDF::PDF }
  end
end
