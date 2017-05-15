require 'rails_helper'

describe EpubConverter do
  let(:user) { FactoryGirl.create :user }
  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_creator_role,
      pdf_css: 'body { background-color: red; }'
    )
  end
  let(:paper) { FactoryGirl.create :paper, :with_creator, journal: journal }
  let(:task) { FactoryGirl.create(:supporting_information_task) }

  let(:converter) do
    EpubConverter.new(
      paper,
      user)
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

  # These tests previously did some epub HTML DOM interrogation that in reality
  # should only take place in IHAT. TAHI should no longer be including HTML
  # content in epubs when sending manuscript content to IHAT

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
    context 'paper with uploaded source' do
      let(:file) do
        File.open(Rails.root.join('spec', 'fixtures', 'about_cats.doc'), 'r')
      end

      before do
        allow(converter).to receive(:manuscript_source).and_return(file)
        allow(converter).to receive(:manuscript_source_contents).and_return(file.read)
        allow(converter).to receive(:_manuscript_source_path)
          .and_return(Pathname.new(file.path))
      end

      it 'returns a stream of data' do
        expect(converter.epub_stream.string.length).to be > 0
      end

      it "includes the source file, calling it 'source' with same
          file extension" do
        entries = read_epub_stream(converter.epub_stream)
        expect(entries.map(&:name)).to include('input/source.doc')
      end

      context 'when the file is named something.DOC' do
        before do
          path = Pathname.new(file.path.gsub(/doc$/, 'DOC'))
          allow(converter).to receive(:_manuscript_source_path)
            .and_return(path)
        end

        it "downcases the extension name" do
          entries = read_epub_stream(converter.epub_stream)
          expect(entries.map(&:name)).to include('input/source.doc')
        end
      end

    end

  end
end
