require 'rails_helper'

describe EpubConverter do
  let(:user) { create :user }
  let(:journal) { create :journal, pdf_css: 'body { background-color: red; }' }
  let(:paper) { create :paper, creator: create(:user), journal: journal }
  let(:include_source) { false }
  let(:include_cover_image) { true }

  let(:converter) do
    EpubConverter.new(
      paper,
      user,
      include_source: include_source,
      include_cover_image: include_cover_image)
  end

  let(:doc) { Nokogiri::HTML(converter.epub_html) }

  def read_epub_stream(stream)
    entries = []
    Zip::InputStream.open(stream) do |io|
      while (entry = io.get_next_entry)
        entries << entry
      end
    end
    entries
  end

  describe '#epub_html' do
    context 'a paper' do
      after { expect(doc.errors.length).to be 0 }

      it 'displays HTML in the papers title' do
        paper.title = 'This <i>is</i> the Title'
        epub_doc_title = doc.css('h1').inner_html.to_s
        expect(epub_doc_title).to eq(paper.display_title(sanitized: false))
      end

      it 'includes the paper body as-is, unescaped' do
        expect(converter.epub_html).to include(paper.body)
      end

      context 'when paper has no supporting information files' do
        it 'doesnt have supporting information' do
          expect(paper.supporting_information_files.empty?).to be true
          expect(doc.css('#si_header').count).to be 0
        end
      end

      context 'when paper has supporting information files' do
        let(:file) do
          paper.supporting_information_files
            .create! attachment: ::File.open('spec/fixtures/yeti.tiff')
        end

        it 'has have supporting information' do
          expect(file)
          expect(paper.supporting_information_files.length).to be 1
          expect(doc.css('#si_header').count).to be 1
          expect(doc.css("img#si_preview_#{file.id}").count).to be 1
          expect(doc.css("a#si_link_#{file.id}").count).to be 1
        end

        it 'the si_preview urls are full-path non-expiring proxy urls' do
          expect(file)
          expect(doc.css('.si_preview').count).to be 1
          expect(doc.css('.si_preview').first['src'])
            .to eq(file.non_expiring_proxy_url(
                     version: :preview, only_path: false))
        end

        it 'the si_link urls are full-path non-expiring proxy urls' do
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

        it 'replaces img src urls (which are normally relative proxied) with
          full-path proxy urls' do
          figure = paper.figures.first
          paper.body = "<img id='figure_#{figure.id}' src='foo'/>"

          img = doc.css("img#figure_#{figure.id}").first
          expect(img['src'])
            .to eq(figure.non_expiring_proxy_url(
                     version: :detail, only_path: false))
        end

        it 'works with orphan figures' do
          # add another figure
          paper.figures
            .create attachment: File.open('spec/fixtures/yeti.tiff'),
                    status: 'done'
          fig1, fig2 = paper.figures
          paper.body = "<img id='figure_#{fig1.id}' src='foo'/>"
          expect(converter.orphan_figures).to eq([fig2])

          expect(doc.css("img#figure_#{fig2.id}").first['src'])
            .to eq(fig2.non_expiring_proxy_url(
                     version: :preview,
                     only_path: false))
        end
      end
    end
  end

  describe '#title' do
    context 'short_title is nil because it has not been set yet' do
      let(:paper) { FactoryGirl.build(:paper) }

      it 'return empty title' do
        expect(converter.title).to eq('')
      end
    end

    context 'short_title is safely escaped' do
      let(:paper) do
        FactoryGirl.create(
          :paper,
          :with_short_title,
          short_title: '<b>my title</b>')
      end

      it 'return empty title' do
        expect(converter.title).to eq('&lt;b&gt;my title&lt;/b&gt;')
      end
    end
  end

  describe '#epub_stream' do
    it 'returns a stream of data' do
      expect(converter.epub_stream.string.length).to be > 0
    end

    context 'paper with no uploaded source' do
      it 'has no source in the epub' do
        entries = read_epub_stream(converter.epub_stream)
        expect(entries.map(&:name)).to_not include(/source/)
      end
    end

    context 'when cover image is requested' do
      let(:include_cover_image) { true }
      it 'includes the journal cover image in the epub' do
        VCR.use_cassette('epub cover image') do
          allow(journal).to receive_message_chain('epub_cover.file.url')
            .and_return('http://example.com/cover_image.jpg')
          entries = read_epub_stream(converter.epub_stream)
          cover = entries.any? { |f| f.name == 'OEBPS/images/cover_image.jpg' }
          expect(cover).to be(true)
        end
      end
    end

    context 'paper with uploaded source' do
      let(:file) do
        File.open(Rails.root.join('spec', 'fixtures', 'about_cats.doc'), 'r')
      end

      before do
        allow(converter).to receive(:manuscript_source).and_return(file)
        allow(converter).to receive(:manuscript_contents).and_return(file.read)
        allow(converter).to receive(:_manuscript_source_path)
          .and_return(Pathname.new(file.path))
      end

      context 'when source is requested' do
        let(:include_source) { true }

        it "includes the source file, calling it 'source' with same
          file extension" do
          entries = read_epub_stream(converter.epub_stream)
          expect(entries.map(&:name)).to include('input/source.doc')
        end
      end

      context 'when source is not requested' do
        let(:include_source) { false }

        it 'does not include the source file' do
          entries = read_epub_stream(converter.epub_stream)
          expect(entries.map(&:name)).to_not include('input/source.doc')
        end
      end
    end

    describe '#publishing_information_html' do
      context 'when downloader is not specified' do
        it 'does not error' do
          expect(converter.publishing_information_html).to be_a(String)
        end
      end
    end
  end
end
