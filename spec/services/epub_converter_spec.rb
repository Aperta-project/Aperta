require 'spec_helper'

describe EpubConverter do
  let(:paper_title) { 'This is a Title About Turtles' }
  let(:paper_body) do
    "<h2 class=\"subtitle\">And this is my subtitle about how turtles are awesome</h2><p>Turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles.</p><p><a name=\"_GoBack\"></a>The end.</p>"
  end
  let(:paper) do
    create :paper, body: paper_body, short_title: paper_title, user: create(:user)
  end

  def read_epub_stream(stream)
    entries = []
    Zip::InputStream.open(stream) do |io|
      while (entry = io.get_next_entry)
        entries << entry
      end
    end
    entries
  end

  describe '#convert' do
    it 'returns a stream of data to the controller' do
      epub = EpubConverter.convert(paper)
      expect(epub[:stream]).to be_a StringIO
      expect(epub[:file_name]).to end_with '.epub'
    end

    context 'empty paper body' do
      let(:paper) do
        create :paper, body: nil, short_title: 'Paper with no body', user: create(:user)
      end

      it 'returns paper body with default text' do
        expect { EpubConverter.convert(paper) }.to_not raise_error
      end
    end

    context 'paper with no uploaded source' do
      it "has no source in the epub" do
        epub = EpubConverter.convert(paper)[:stream]
        entries = read_epub_stream(epub)
        expect(entries.any? { |f| f.name =~ /source\.docx/ }).to eq(false)
      end

      it "does not include a source even when requested" do
        epub = EpubConverter.convert(paper, true)[:stream]
        entries = read_epub_stream(epub)
        expect(entries.any? { |f| f.name =~ /source\.docx/ }).to eq(false)
      end
    end

    context 'paper with uploaded source' do
      let(:paper) { create :paper }
      let!(:manuscript)  { FactoryGirl.create(:manuscript, paper: paper) }

      it "includes the source doc in the epub when requested" do
        epub = EpubConverter.convert(paper, true)[:stream]
        entries = read_epub_stream(epub)
        expect(entries.any? { |f| f.name =~ /source\.docx/ }).to eq(true)
      end

      it "does not include the source doc in the epub when not requested" do
        epub = EpubConverter.convert(paper)[:stream]
        entries = read_epub_stream(epub)
        expect(entries.any? { |f| f.name =~ /source\.docx/ }).to eq(false)
      end
    end
  end
end
