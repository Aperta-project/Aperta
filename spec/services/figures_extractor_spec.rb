require "rails_helper"

describe FiguresExtractor do

  let(:extractor) { FiguresExtractor.new("fake_stream") }
  let(:image_stream_1) do
    FileStringIO.new("resource_1.gif", File.open(Rails.root.join('spec', 'fixtures', '5x5-sample-image.gif'), 'rb').read)
  end
  let(:image_stream_2) do
    FileStringIO.new("resource_2.gif", File.open(Rails.root.join('spec', 'fixtures', '5x5-sample-image.gif'), 'rb').read)
  end
  let(:paper_body) do
    <<-html
      <html>
        <body>
          <div>
            <img src="images/resource_1.gif" alt="" class="block">
          </div>
          <p class="Normal">Using the word resource without anchor tag here.</p>
          <img src="images/resource_2.gif" alt="" class="block">
        </body>
      </html>
    html
  end
  let(:paper) do
    FactoryGirl.create(:paper).tap do |paper|
      paper.body = paper_body
      paper.save
    end
  end

  describe "sync!" do
    before do
      allow(extractor).to receive(:images).and_return([image_stream_1, image_stream_2])
    end

    it "creates a Figure for each image in the epub" do
      expect{ extractor.sync!(paper) }.to change(paper.figures, :count).by(2)
    end

    it "does not increase paper versions" do
      expect{ extractor.sync!(paper) }.to_not change(paper.versioned_texts, :count)
    end

    it "replaces the existing image anchor tags with Figure URLs" do
      extractor.sync!(paper)
      expect(paper.body).to_not match(/images\/resource_\d.gif/)
      expect(paper.body).to have_s3_url(paper.figures.first.attachment.preview.url)
      expect(paper.body).to have_s3_url(paper.figures.last.attachment.preview.url)
    end
  end
end
