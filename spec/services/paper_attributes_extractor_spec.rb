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

      it "updates ONLY the paper body" do
        expect(paper).to receive(:update!).with(body: content)
        extractor.sync!(paper)
      end
    end
  end
end
