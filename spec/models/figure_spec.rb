require 'rails_helper'
require 'models/concerns/striking_image_shared_examples'

describe Figure, redis: true do
  let(:figure) {
    with_aws_cassette('figure') do
      FactoryGirl.create :figure,
                          attachment: File.open('spec/fixtures/yeti.tiff'),
                          status: 'done'
    end
  }

  it_behaves_like 'a striking image'

  describe '#access_details' do
    it 'returns a hash with attachment src, filename, alt' do
      expect(figure.access_details).to eq(filename: 'yeti.tiff',
                                          alt: 'Yeti',
                                          src: figure.non_expiring_proxy_url,
                                          id: figure.id)
    end
  end

  describe '#src' do
    it 'returns nil if status is not done' do
      figure.status = 'processing'
      expect(figure.src).to be_nil
    end

    it 'returns a path with figure id for the proxy image endpoint' do
      expect(figure.src).to eq figure.non_expiring_proxy_url
    end
  end

  describe '#preview_src' do
    it 'returns nil if status is not done' do
      figure.status = 'processing'
      expect(figure.preview_src).to be_nil
    end

    it 'returns a path with figure id for the proxy image endpoint' do
      expect(figure.preview_src)
        .to eq figure.non_expiring_proxy_url(version: :preview)
    end
  end

  describe '#detail_src' do
    it 'returns nil if status is not done' do
      figure.status = 'processing'
      expect(figure.detail_src).to be_nil
    end

    it 'returns a path with figure id for the proxy image endpoint' do
      expect(figure.detail_src)
        .to eq figure.non_expiring_proxy_url(version: :detail)
    end
  end

  describe '.acceptable_content_type?' do
    it 'accepts standard image types' do
      %w{gif jpg jpeg png tiff}.each do |type|
        expect(Figure.acceptable_content_type? "image/#{type}").to eq true
      end
    end

    it 'rejects non-image types' do
      %w{doc docx pdf epub raw bmp}.each do |type|
        expect(Figure.acceptable_content_type? "image/#{type}").to eq false
      end
    end
  end

  describe 'removing the attachment' do
    it 'destroys the attachment on destroy' do
      # remove_attachment! is a built-in callback.
      # this spec exists so that we don't duplicate that behavior
      expect(figure).to receive(:remove_attachment!)
      figure.destroy
    end
  end

  describe 'rank' do
    it 'coerces the title into an integer if able' do
      figure = create :figure, title: "Fig 1"
      expect(figure.rank).to eq 1

      figure.update!(title: "Figure 2")
      expect(figure.rank).to eq 2

      figure.update!(title: "42")
      expect(figure.rank).to eq 42
    end

    it 'is nil if the title can not be coerced into an integer' do
      figure = create :figure, title: "I didn't follow instructions"
      expect(figure.rank).to be_nil
    end

    it 'is nil if the title is nil' do
      figure = create :figure, title: nil
      expect(figure.rank).to be_nil
    end
  end
end
