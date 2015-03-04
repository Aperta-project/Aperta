require 'rails_helper'

def Faraday.get(arg); super; end

describe PaperUpdateWorker do
  subject(:worker) { PaperUpdateWorker.new }
  let(:paper) { FactoryGirl.create :paper }

  describe "#perform" do
    let(:stubbed_url) { "s3_url_example" }
    let(:turtles_fixture) { File.open(Rails.root.join('spec', 'fixtures', 'turtles.epub'), 'rb').read }

    before do
      epub_response = double(:epub, body: turtles_fixture)
      expect(Faraday).to receive(:get).with(stubbed_url).and_return(epub_response)
    end

    it "requests attribute extraction" do
      expect_any_instance_of(PaperAttributesExtractor).to receive(:sync!)
      worker.perform(paper.id, stubbed_url)
    end

    it "requests figure extraction" do
      expect_any_instance_of(FiguresExtractor).to receive(:sync!)
      worker.perform(paper.id, stubbed_url)
    end
  end
end
