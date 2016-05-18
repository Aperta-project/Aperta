require 'rails_helper'

describe PDFConverter do
  let(:user) { FactoryGirl.create :user }
  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_roles_and_permissions,
      pdf_css: 'body { background-color: red; }'
    )
  end
  let(:paper) { FactoryGirl.create :paper, :with_creator, journal: journal }
  let(:converter) { PDFConverter.new(paper, user) }

  describe '#convert' do
    it 'uses PDFKit to generate PDF' do
      expect(PDFKit).to receive_message_chain(:new, :to_pdf)
      converter.convert
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
        paper.supporting_information_files
          .create! attachment: ::File.open('spec/fixtures/yeti.tiff')
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
          .to have_s3_url(file.attachment.url(:preview))
      end

      it 'the si_link urls are non-expiring proxy urls' do
        expect(file)
        expect(doc.css('.si_link').count).to be 1
        expect(doc.css('.si_link').first['href'])
          .to eq file.non_expiring_proxy_url(only_path: false)
      end
    end

    context 'when paper has figures' do
      before do
        paper.figures
          .create attachment: File.open('spec/fixtures/yeti.tiff'),
                  status: 'done'
      end

      it 'replaces img src urls (which are normally proxied) with resolveable
        urls' do
        figure = paper.figures.first
        paper.body = "<p>Figure 1.</p>"
        img = doc.css("img").first
        expect(img['src']).to have_s3_url figure.proxyable_url(version: :detail)
      end
    end
  end
end
