require 'rails_helper'

# Defining explicitly to override verifying partial double.
# See here: https://relishapp.com/rspec/rspec-mocks/v/3-0/docs/verifying-doubles/dynamic-classes
#
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

    it "updates the paper's title and body" do
      worker.perform(paper.id, stubbed_url)
      paper.reload
      expect(paper.body).to eq("<p>This is a stubbed turtle file</p>")
      expect(paper.title).to eq("This is a title about turtles.")
    end
  end
end
