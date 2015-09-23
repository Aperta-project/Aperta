require 'rails_helper'

describe EpubConverter do
  let(:paper_title) { 'This is a Title About Turtles' }
  let(:paper_body) do
    "<h2 class=\"subtitle\">And this is my subtitle about how turtles are awesome</h2><p>Turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles.</p><p><a name=\"_GoBack\"></a>The end.</p>"
  end
  let(:paper) do
    create :paper, body: paper_body, short_title: paper_title, creator: create(:user)
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
  let(:converter) { EpubConverter.new paper, downloader, include_source }

  describe '#epub_html' do
    context 'a paper' do
      let(:doc) { Nokogiri::HTML(converter.epub_html) }

      after { expect(doc.errors.length).to be 0 }

      it "displays and HTML escapes the paper's short_title" do
        paper.short_title = "<This Is & The Short Title>"
        expect(doc).to have_path("title:contains('#{paper.short_title}')")
      end

      it "displays and HTML escapes the paper's title" do
        paper.title = "<This Is & The Title>"
        expect(doc).to have_path("h1:contains('#{paper.title}')")
      end

      it "includes the paper body as-is, unescaped" do
        expect(converter.epub_html).to include(paper.body)
      end
    end

    context 'paper with empty title' do
      let(:paper) { create :paper, title: nil, body: "<div>paper body here</div>" }

      it 'should use the short title' do
        expect(converter.epub_html).to have_path("h1:contains('#{paper.short_title}')")
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
        expect(entries.any? { |f| f.name =~ /source\.docx/ }).to eq(false)
      end
    end

    context 'paper with uploaded source' do
      let(:file) { File.open(Rails.root.join("spec", "fixtures", "about_turtles.docx"), 'r') }

      before do
        paper.create_manuscript!
        allow(converter).to receive(:manuscript_source).and_return(file)
        allow(converter).to receive(:manuscript_contents).and_return(file.read)
      end

      context 'when source is requested' do
        let(:include_source) { true }

        it "includes the source doc in the epub" do
          entries = read_epub_stream(converter.epub_stream)
          expect(entries.any? { |f| f.name =~ /source\.docx/ }).to eq(true)
        end
      end

      context 'when source is not requested' do
        let(:include_source) { false }
        it "does not include the source doc in the epub" do
          entries = read_epub_stream(converter.epub_stream)
          expect(entries.any? { |f| f.name =~ /source\.docx/ }).to eq(false)
        end
      end
    end
  end
end
