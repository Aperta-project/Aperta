require 'rails_helper'

describe PaperConverters::PdfWithAttachmentsPaperConverter do
  let(:export_format) { 'pdf' }
  let(:paper) { create(:paper, :version_with_file_type, :with_creator) }
  let(:figure_count) { 2 }
  let!(:figures) { create_list(:figure, figure_count, owner: paper).tap { paper.reload } }
  let(:paper_version) { paper.latest_version }
  let(:converter) { PaperConverters::PdfWithAttachmentsPaperConverter.new(paper_version, export_format) }
  let(:pdf_data) { File.read(Rails.root.join('spec/fixtures/about_turtles.pdf')) }

  it_behaves_like "a synchronous paper converter"

  describe "#output_filename" do
    subject { converter.output_filename }
    it { is_expected.to eq "#{paper.short_doi} - #{paper.creator.last_name} - #{paper_version.version} (with attachments).pdf" }
  end

  # More coverage in pdf_with_attachments.html.erb_spec.rb
  describe "#create_attachments_html" do
    it "creates an html document that contains all of the figures" do
      html = converter.create_attachments_html
      expect(html).to match(/img/)
    end
  end

  describe "#create_attachments_pdf" do
    subject { converter.create_attachments_pdf }

    before do
      allow(converter).to receive(:create_attachments_html).and_return <<-HTML
        <html>
        <body>
          <p>a fake document</p>
        </body>
        </html>
      HTML
    end

    it { is_expected.to be_an_instance_of CombinePDF::PDF }
  end

  describe "#uploaded_pdf_data" do
    subject { converter.uploaded_pdf_data }

    it "retreives a resource from s3", vcr: { cassette_name: "pdf_file" } do
      allow(Attachment).to receive(:authenticated_url_for_key)
        .and_return("https://fake-aws/about_turtles.pdf")
      expect(subject).to be_present
    end
  end

  describe "#parsed_uploaded_pdf" do
    subject { converter.parsed_uploaded_pdf }
    before do
      allow(converter).to receive(:uploaded_pdf_data).and_return(pdf_data)
    end

    it { is_expected.to be_an_instance_of CombinePDF::PDF }
  end

  describe "#call_qpdf" do
    let(:in_file_path) { Rails.root.join('/tmp/infile.pdf') }
    let(:out_file_path) { Rails.root.join('/tmp/outfile.pdf') }
    it 'performs a system call' do
      expect(converter).to receive(:system).with(/\Aqpdf/)
      converter.call_qpdf(in_file_path, out_file_path)
    end
  end

  describe "#pdf_may_have_object_stream?" do
    let(:object_streams_pdf) do
      Rails.root.join('spec/fixtures/object_streams.pdf')
    end
    let(:no_object_streams_pdf) do
      Rails.root.join('spec/fixtures/no_object_streams.pdf')
    end

    context "when PDF has object streams" do
      subject { converter.pdf_may_have_object_stream?(object_streams_pdf) }
      it 'should be true' do
        subject.should be(true)
      end
    end

    context "when PDF has no object streams" do
      subject { converter.pdf_may_have_object_stream?(no_object_streams_pdf) }
      it 'should be false' do
        subject.should be(false)
      end
    end
  end

  describe "#figures" do
    subject { converter.figures }

    it "is a list of FigureProxy objects" do
      expect(subject.count).to eq figure_count
      subject.each do |obj|
        expect(obj).to be_an_instance_of PaperConverters::FigureProxy
      end
    end
  end

  describe "#supporting_information_files" do
    let(:si_count) { 2 }
    let!(:supporting_information_files) do
      create_list :supporting_information_file, si_count, paper: paper
    end

    subject { converter.supporting_information_files }

    it "is a list of SupportingInformationFile objects" do
      expect(subject.count).to eq si_count
      subject.each do |obj|
        expect(obj).to be_an_instance_of PaperConverters::SupportingInformationFileProxy
      end
    end
  end

  describe "#merge_pdfs" do
    let(:pdfs) { Array.new(2) { CombinePDF.parse pdf_data } }
    subject { converter.merge_pdfs(pdfs) }

    it "combines multiple PDF objects into a single PDF object" do
      expect(subject).to be_an_instance_of CombinePDF::PDF
    end
  end

  describe "#output_data" do
    subject { converter.output_data }
    let(:sample_combine_pdf) { CombinePDF.parse pdf_data }

    before do
      allow(converter).to receive(:parsed_uploaded_pdf).and_return(sample_combine_pdf)
      allow(converter).to receive(:create_attachments_pdf).and_return(sample_combine_pdf)
    end

    it { is_expected.to be_present }
  end
end
