require 'rails_helper'

describe PaperConverters::PdfPaperConverter do
  let(:export_format) { 'pdf' }
  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_creator_role,
      pdf_css: 'body { background-color: red; }'
    )
  end
  let(:user) { FactoryGirl.create :user }
  let(:paper) { create(:paper, :version_with_file_type, :with_creator, journal: journal) }
  let(:versioned_text) { paper.latest_version }
  let(:task) { FactoryGirl.create(:supporting_information_task) }
  let(:converter) { PaperConverters::PdfPaperConverter.new(versioned_text, export_format, user) }


  it_behaves_like "a synchronous paper converter"

  describe "#output_filename" do
    subject { converter.output_filename }
    it { is_expected.to match(/.+\.pdf/) }
  end

  describe "#output_filetype" do
    subject { converter.output_filetype }
    it { is_expected.to eq('application/pdf') }
  end

  describe '#output_data' do
    it 'uses PDFKit to generate PDF' do
      expect(PDFKit).to receive_message_chain(:new, :to_pdf)
      converter.output_data
    end
  end

  describe '.pdf_html' do
    let(:doc) { Nokogiri::HTML(pdf_html) }
    let(:pdf_html) { converter.pdf_html }

    after { expect(doc.errors.length).to be 0 }

    it 'includes all necessary info and default journal stylesheet
      in the generated HTML' do
      expect(pdf_html).to include journal.pdf_css
      expect(pdf_html).to include paper.display_title(sanitized: false)
      expect(pdf_html).to include paper.body
    end

    it "displays HTML in the paper's title" do
      paper.title = 'This <i>is</i> the Title'
      pdf_doc_title = doc.css('#paper-body h1').inner_html.to_s
      expect(pdf_doc_title).to eq(paper.display_title(sanitized: false))
    end

    context 'when paper has no supporting information files' do
      it 'doesnt have supporting information' do
        expect(paper.supporting_information_files.empty?).to be true
        expect(pdf_html).not_to include 'Supporting Information'
      end
    end

    context 'when paper has supporting information files' do
      let(:file) do
        paper.supporting_information_files.create!(
          resource_tokens: [ResourceToken.new(version_urls: { preview: Faker::Internet.url })],
          owner: task,
          file: ::File.open('spec/fixtures/yeti.tiff')
        )
      end

      it 'has supporting information' do
        expect(file).to be_truthy
        expect(paper.supporting_information_files.length).to be 1
        expect(doc.css('#si_header').count).to be 1
        expect(doc.css("img#si_preview_#{file.id}").count).to be 1
        expect(doc.css("a#si_link_#{file.id}").count).to be 1
      end

      it 'the si_preview urls are to S3' do
        # because they need to resolve at create time for pdf
        expect(file)
        expect(doc.css('.si_preview').count).to be 1
        expect(doc.css('.si_preview').first['src'])
          .to have_s3_url(file.file.url(:preview))
      end

      it 'the si_link urls are non-expiring proxy urls' do
        expect(file)
        expect(doc.css('.si_link').count).to be 1
        expect(doc.css('.si_link').first['href'])
          .to eq file.non_expiring_proxy_url(only_path: false)
      end
    end

    context 'when paper has figures' do
      let(:figure) { paper.figures.first }
      let(:figure_img) { doc.css('img').first }

      before do
        paper.figures.create!(
          resource_tokens: [ResourceToken.new],
          file: File.open('spec/fixtures/yeti.tiff'),
          status: Figure::STATUS_DONE
        )

        paper.update_attributes(body: "<p>Figure 1.</p>")
      end

      it 'replaces img src urls (which are normally proxied) with resolveable urls' do
          expected_uri = URI.parse(figure.proxyable_url)
          actual_uri = URI.parse(figure.proxyable_url)
          allow(Attachment).to receive(:authenticated_url_for_key).and_return figure.proxyable_url
          expect(actual_uri.scheme).to eq expected_uri.scheme
          expect(actual_uri.host).to eq expected_uri.host
          expect(actual_uri.path).to eq expected_uri.path
          expect(CGI.parse(actual_uri.query).keys).to \
            contain_exactly(
              'X-Amz-Expires',
              'X-Amz-Date',
              'X-Amz-Algorithm',
              'X-Amz-Credential',
              'X-Amz-SignedHeaders',
              'X-Amz-Signature'
            )
      end

      it 'has the proper css class to prevent figures spanning multiple lines' do
        allow(Attachment).to receive(:authenticated_url_for_key).and_return figure.proxyable_url
        expect(figure_img['class']).to include("pdf-image",
                                               "pdf-image-with-caption")
      end
    end
  end
end
