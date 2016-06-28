require 'rails_helper'
require 'models/concerns/striking_image_shared_examples'

describe Figure, redis: true do
  let(:figure) do
    with_aws_cassette('figure') do
      FactoryGirl.create(
        :figure,
        file: File.open('spec/fixtures/yeti.tiff'),
        status: Figure::STATUS_DONE
      )
    end
  end

  it_behaves_like 'a striking image'

  describe '#access_details' do
    it 'returns a hash with file src, filename, alt' do
      expect(figure.access_details).to eq(filename: 'yeti.tiff',
                                          alt: 'Yeti',
                                          src: figure.non_expiring_proxy_url,
                                          id: figure.id)
    end
  end

  describe '#download!', vcr: { cassette_name: 'figures' } do
    subject(:figure) { FactoryGirl.create(:figure, title: nil, owner: paper) }
    let(:paper) { FactoryGirl.create(:paper) }
    let(:url) { 'http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg' }

    include_examples 'attachment#download! stores the file'
    include_examples 'attachment#download! caches the s3 store_dir'
    include_examples 'attachment#download! sets the file_hash'
    include_examples 'attachment#download! sets the status'
    include_examples 'attachment#download! knows when to keep and remove s3 files'

    it 'sets the title, status, and rank' do
      figure.download!(url)
      figure.reload
      expect(figure.title).to eq('Unlabeled')
      expect(figure.status).to eq(self.described_class::STATUS_DONE)
      expect(figure.rank).to eq(0)
    end

    it 'does not set the title when it is already set' do
      figure.update_column(:title, 'Great picture!')
      expect do
        figure.download!(url)
      end.to_not change { figure.reload.title }.from('Great picture!')
    end

    context 'when the figure is labeled', vcr: { cassette_name: 'labeled_figures'} do
      let(:url) { 'http://tahi-test.s3.amazonaws.com/temp/fig-1.jpg' }
      it 'sets the figure title and rank from the label' do
        figure.download!(url)
        figure.reload
        expect(figure.title).to eq('Fig. 1')
        expect(figure.rank).to eq(1)
      end
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

    it 'returns a path with a cache buster if requested' do
      url = figure.detail_src(cache_buster: true)
      expect(url).to match /\?cb=\w+$/
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

  describe 'removing the file' do
    it 'destroys the file on destroy' do
      # remove_file! is a built-in callback.
      # this spec exists so that we don't duplicate that behavior
      expect(figure).to receive(:remove_file!)
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

    it 'is 0 if the title can not be coerced into an integer' do
      figure = create :figure, title: "I didn't follow instructions"
      expect(figure.rank).to eq 0
    end

    it 'is 0 if the title is nil' do
      figure = create :figure, title: nil
      expect(figure.rank).to eq 0
    end
  end

  describe 'inserting figures into a paper' do
    let(:paper_double) { double 'paper' }

    it 'triggers when the figure title is updated' do
      allow(figure).to receive(:paper).and_return(paper_double)
      allow(figure).to receive(:all_figures_done?).and_return(true)
      expect(paper_double).to receive(:insert_figures!)

      figure.update!(title: 'new title')
    end

    it 'triggers when the figure is destroyed' do
      allow(figure).to receive(:paper).and_return(paper_double)
      expect(paper_double).to receive(:insert_figures!)
      allow(paper_double).to receive(:id)

      figure.destroy!
    end

    it 'triggers if the file is updated' do
      expect(figure).to receive(:insert_figures!)
      with_aws_cassette('figure') do
        figure.update!(file: File.open('spec/fixtures/yeti.jpg'))
      end
    end
  end

  describe '#file_exists?' do
    context 'when the file is present' do
      it 'returns true' do
        expect(figure.file?).to eq true
      end
    end
  end
end
