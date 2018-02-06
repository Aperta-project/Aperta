require 'rails_helper'

describe Figure, redis: true do
  let(:figure) do
    with_aws_cassette('attachment') do
      FactoryGirl.create(
        :figure,
        :with_resource_token,
        file: File.open('spec/fixtures/yeti.tiff'),
        status: Figure::STATUS_DONE
      )
    end
  end

  describe '#access_details' do
    it 'returns a hash with file src, filename, alt' do
      expect(figure.access_details).to eq(filename: 'yeti.tiff',
                                          alt: 'Yeti',
                                          src: figure.non_expiring_proxy_url,
                                          id: figure.id)
    end
  end

  describe '#download!', vcr: { cassette_name: 'attachment' } do
    subject(:figure) do
      create(
        :figure,
        :unprocessed,
        owner: paper
      )
    end
    let(:paper) { FactoryGirl.create(:paper) }
    let(:url) { 'http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg' }

    it_behaves_like 'attachment#download! raises exception when it fails'
    it_behaves_like 'attachment#download! stores the file'
    it_behaves_like 'attachment#download! caches the s3 store_dir'
    it_behaves_like 'attachment#download! sets the file_hash'
    it_behaves_like 'attachment#download! sets the status'
    it_behaves_like 'attachment#download! always keeps snapshotted files on s3'
    it_behaves_like 'attachment#download! manages resource tokens'
    it_behaves_like 'attachment#download! sets the updated_at'
    it_behaves_like 'attachment#download! sets the error fields'
    it_behaves_like 'attachment#download! when the attachment is invalid'

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
        expect(figure.title).to eq('Fig 1')
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
    let(:paper) { FactoryGirl.build_stubbed :paper }
    before do
      figure.paper = paper
    end

    it 'triggers when the figure title is updated' do
      allow(figure).to receive(:all_figures_done?).and_return(true)
      expect(paper).to receive(:insert_figures!)

      figure.update!(title: 'new title')
    end

    it 'triggers when the figure is destroyed' do
      expect(paper).to receive(:insert_figures!)

      figure.destroy!
    end

    it 'triggers if the file is downloaded' do
      expect(figure).to receive(:insert_figures!)
      with_aws_cassette('attachment') do
        figure.download!('http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg')
      end
    end
  end

  describe '#file?' do
    context 'when the file is present' do
      it 'returns true' do
        expect(figure.file?).to eq true
      end
    end
  end

  describe '#build_title' do
    let(:figure) { create :figure, :unprocessed }

    it 'returns the title if it is set' do
      figure.title = Faker::Lorem.word
      expect(figure.send(:build_title)).to eq(figure.title)
    end

    it 'returns the results of title_from_filename' do
      title = Faker::Lorem.word
      expect(figure).to receive(:title_from_filename).and_return(title)
      expect(figure.send(:build_title)).to eq(title)
    end

    it 'returns "Unlabeled" otherwise' do
      expect(figure).to receive(:title_from_filename).and_return(nil)
      expect(figure.send(:build_title)).to eq('Unlabeled')
    end
  end

  describe '#title_from_filename' do
    ["Figure 1", "figure 1", "fig. 1", "fig_1", "fig+1", "fig#1", "foo/fig%231"].each do |filename|
      it "returns 'Fig 1' when file is named #{filename}.tiff" do
        expect(figure).to receive(:pending_url).twice.and_return("#{filename}.tiff")
        expect(figure.send(:title_from_filename)).to eq("Fig 1")
      end
    end

    ["1.tiff", "Figure.tiff", "Figure S1.tiff", "Figure ABC.tiff", "abc.tiff", "abc 1.tiff"].each do |filename|
      it "returns nil when file is named #{filename}" do
        expect(figure).to receive(:pending_url).twice.and_return(filename)
        expect(figure.send(:title_from_filename)).to be_nil
      end
    end
  end
end
