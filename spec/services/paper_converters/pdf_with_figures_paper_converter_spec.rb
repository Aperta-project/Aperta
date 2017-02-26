require 'rails_helper'

describe PaperConverters::PdfWithFiguresPaperConverter do
  let(:export_format) { 'pdf' }
  let(:paper) { create(:paper, :version_with_file_type) }
  let!(:figures) { create_list(:figure, 2, owner: paper).tap { paper.reload } }
  let(:versioned_text) { paper.latest_version }
  let(:converter) { PaperConverters::PdfWithFiguresPaperConverter.new(versioned_text, export_format) }

  # More coverage in pdf_with_figures.html.erb_spec.rb
  describe "#create_figures_html" do
    it "creates an html document that contains all of the figures" do
      html = converter.create_figures_html
      expect(html).to match(/img/)
    end
  end
end
