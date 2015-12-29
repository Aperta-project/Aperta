require 'rails_helper'

describe PDFConverter do
  let(:user) { create :user }
  let(:journal) { create :journal, pdf_css: 'body { background-color: red; }' }
  let(:paper) { create :paper, creator: create(:user), journal: journal }
  let(:converter) { PDFConverter.new(paper, user) }

  describe '#convert' do
    it 'uses PDFKit to generate PDF' do
      expect(PDFKit).to receive_message_chain(:new, :to_pdf)
      PDFConverter.new(paper, user).convert
    end
  end

  describe '.pdf_html' do
    let(:doc) { Nokogiri::HTML(pdf_html) }
    let(:pdf_html) { PDFConverter.new(paper, user).pdf_html }

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
        with_aws_cassette 'supporting_info_files_controller' do
          paper.supporting_information_files
            .create! attachment: ::File.open('spec/fixtures/yeti.tiff')
        end
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
          .to have_s3_url(file.attachment.url)
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
        with_aws_cassette('figure') do
          paper.figures
            .create attachment: File.open('spec/fixtures/yeti.tiff'),
                    status: 'done'
        end
      end

      it 'replaces img src urls (which are normally proxied) with resolveable
        urls' do
        # since pdfs maker apparently cant resolve proxy url for img.src
        # this will completed in https://developer.plos.org/jira/browse/APERTA-5741

        figure = paper.figures.first
        allow(paper).to receive(:body)
          .and_return("<img id='figure_#{figure.id}' src='foo'/>")

        img = doc.css("img#figure_#{figure.id}").first
        expect(img['src']).to have_s3_url(figure.attachment.url)
      end

      it 'works with orphan figures' do
        # add another figure
        with_aws_cassette('figure') do
          paper.figures
            .create attachment: File.open('spec/fixtures/yeti.tiff'),
                    status: 'done'
        end
        fig1, fig2 = paper.figures
        allow(paper).to receive(:body)
          .and_return("<img id='figure_#{fig1.id}' src='foo'/>")
        expect(converter.orphan_figures).to eq([fig2])

        expect(doc.css("img#figure_#{fig2.id}").first['src']).to \
          eq(fig2.attachment.url)
      end
    end
  end
end
