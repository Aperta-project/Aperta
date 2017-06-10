require "rails_helper"

describe PaperAttributesExtractor do
  let(:extractor) { PaperAttributesExtractor.new("fake_stream") }
  let(:paper) { FactoryGirl.create :paper }

  describe "#sync!" do
    context "updating body" do
      let(:content) { "<p>This is a stubbed turtle file</p>" }

      before do
        allow(extractor).to receive(:extract_file) do |filename|
          content if filename == "body"
        end
      end

      it "updates the paper body" do
        extractor.sync!(paper)
        expect(paper.reload.body).to eq(content)
      end
    end

    context "tahi scraping is not included with title" do
      it "updates title with user input" do
        expect(paper.reload.title).to eq(paper.title)
      end
    end

    context "updating abstract" do
      let(:content) { "My abstract" }

      before do
        allow(paper).to receive(:file_type).and_return 'docx'
        allow(extractor).to receive(:extract_file) do |filename|
          content if filename == "abstract"
        end
      end

      it "updates the paper abstract" do
        extractor.sync!(paper)
        expect(paper.reload.abstract).to eq(content)
      end

      context "when a too-long abstract is returned" do
        let(:content) do
          content = ''
          (1..2000).each do |i|
            content += i.to_s + ' '
          end
          content
        end

        before do
          allow(paper).to receive(:file_type).and_return 'docx'
          allow(extractor).to receive(:extract_file) do |filename|
            content if filename == "abstract"
          end
        end

        it "enforces max abstract length" do
          extractor.sync!(paper)
          expect(paper.reload.abstract).to be_nil
        end
      end
    end
  end
end
