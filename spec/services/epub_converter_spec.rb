require 'rails_helper'

describe EpubConverter do
  let(:paper_title) { 'This is a Title About Turtles' }
  let(:paper_body) do
    "<h2 class=\"subtitle\">And this is my subtitle about how turtles are awesome</h2><p>Turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles.</p><p><a name=\"_GoBack\"></a>The end.</p>"
  end
  let(:journal) do
    FactoryGirl.create(:journal)
  end
  let(:paper) do
    create :paper,
           body: paper_body,
           title: paper_title,
           creator: create(:user),
           journal: journal
  end
  let(:downloader) { FactoryGirl.create :user }

  def read_epub_stream(stream)
    entries = []
    Zip::InputStream.open(stream) do |io|
      while (entry = io.get_next_entry)
        entries << entry
      end
    end
    entries
  end

  let(:include_source) { false }
  let(:include_cover_image) { true }
  let(:converter) do
    EpubConverter.new(
      paper,
      downloader,
      include_source: include_source,
      include_cover_image: include_cover_image)
  end

  describe '#epub_html' do
    context 'a paper' do
      let(:doc) { Nokogiri::HTML(converter.epub_html) }

      after { expect(doc.errors.length).to be 0 }

      it "displays HTML in the paper's title" do
        paper.title = "This <i>is</i> the Title"
        epub_doc_title = doc.css("h1").inner_html.to_s
        expect(epub_doc_title).to eq(paper.display_title(sanitized: false))
      end

      it "includes the paper body as-is, unescaped" do
        expect(converter.epub_html).to include(paper.body)
      end
    end
  end

  describe "#file_name" do
    it "returns placeholder filename" do
      expect(converter.file_name).to eq("paper_#{paper.id}.epub")
    end
  end

  describe "#title" do
    context "short_title is nil because it has not been set yet" do
      let(:paper) { FactoryGirl.build(:paper, short_title: nil) }

      it "return empty title" do
        expect(EpubConverter.new(paper, nil).title).to eq("")
      end
    end

    context "short_title is safely escaped" do
      let(:paper) { FactoryGirl.build(:paper, short_title: "<b>my title</b>") }

      it "return empty title" do
        expect(EpubConverter.new(paper, nil).title).to eq("&lt;b&gt;my title&lt;/b&gt;")
      end
    end
  end

  describe '#epub_stream' do
    it 'returns a stream of data' do
      expect(converter.epub_stream.string.length).to be > 0
    end

    context 'paper with no uploaded source' do
      it "has no source in the epub" do
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
      let(:file) { File.open(Rails.root.join("spec", "fixtures", "about_cats.doc"), 'r') }

      before do
        allow(converter).to receive(:manuscript_source).and_return(file)
        allow(converter).to receive(:manuscript_contents).and_return(file.read)
        allow(converter).to receive(:_manuscript_source_path).and_return(Pathname.new(file.path))
      end

      context 'when source is requested' do
        let(:include_source) { true }

        it "includes the source file, calling it 'source' with same file extension" do
          entries = read_epub_stream(converter.epub_stream)
          expect(entries.map(&:name)).to include("input/source.doc")
        end
      end

      context 'when source is not requested' do
        let(:include_source) { false }

        it "does not include the source file" do
          entries = read_epub_stream(converter.epub_stream)
          expect(entries.map(&:name)).to_not include("input/source.doc")
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
