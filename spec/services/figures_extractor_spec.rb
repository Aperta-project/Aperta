require "rails_helper"

describe FiguresExtractor do

  let(:extractor) { FiguresExtractor.new('fake_stream') }
  let(:image_stream_1) do
    FileStringIO.new('resource_1.gif', File.open(
      Rails.root.join('spec', 'fixtures', '5x5-sample-image.gif'), 'rb').read)
  end
  let(:image_stream_2) do
    FileStringIO.new('resource_2.gif', File.open(
      Rails.root.join('spec', 'fixtures', '5x5-sample-image.gif'), 'rb').read)
  end
  let(:paper_body_from_ihat) do
    <<-html
      <html>
        <body>
          <div class='figure'>
            <img src='images/resource_1.gif' alt=''
                 class='block' style='width:16.991cm; height:8.184cm;'>
          </div>

          <p class='Normal'>Using the word resource without anchor tag here.</p>

          <div class='figure'>
            <img src='images/resource_2.gif' alt=''
                 class='block' style='width:16.991cm; height:8.184cm;'>
          </div>

        </body>
      </html>
    html
  end
  let(:paper) do
    FactoryGirl.create(:paper).tap do |paper|
      paper.body = paper_body_from_ihat
      paper.save
    end
  end

  describe 'sync!' do
    before do
      allow(extractor)
        .to receive(:images).and_return([image_stream_1, image_stream_2])
    end

    it 'does not increase paper versions' do
      expect { extractor.sync!(paper) }
        .to_not change(paper.versioned_texts, :count)
    end

    context 'for all figure image tags in the paper body html' do
      before { extractor.sync!(paper) }

      it 'replaces the existing src attribute with relative non-expiring
        public proxy urls' do
        expect(paper.body).to_not match(%r{images\/resource_\d.gif})
        paper.figures.each do |figure|
          img = img_tag_by_id figure.id
          expect(img['src']).not_to include('http')
          expect(img['src'])
            .to eq(figure.non_expiring_proxy_url(version: :detail))
        end
      end

      it 'gives an appropriate alt attribute' do
        paper.figures.each do |figure|
          img = img_tag_by_id figure.id
          expect(img['alt']).to eq("Figure: #{figure.filename}")
        end
      end

      it 'gives an appropriate data attribute' do
        paper.figures.each do |figure|
          img = img_tag_by_id figure.id
          expect(img['data-figure-id']).to eq(figure.id.to_s)
        end
      end

      it 'replaces style attribute with a flexible alternative' do
        paper.figures.each do |figure|
          img = img_tag_by_id figure.id
          expect(img['style']).to eq(nil)
        end
      end
    end
  end

  def img_tag_by_id(id)
    Nokogiri::HTML(paper.body).css("img#figure_#{id}").first.tap do |img|
      expect(img).to be_truthy
    end
  end
end
