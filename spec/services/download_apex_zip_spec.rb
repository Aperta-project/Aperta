require 'rails_helper'

describe DownloadApexZip do
  let(:paper) { FactoryGirl.create(:paper) }

  it 'creates a zip package for a paper' do
    download = DownloadApexZip.new(paper)
    response = download.export

    expect(response).not_to be_empty
  end

  context 'a paper with figures' do
    let(:figure) do
      FactoryGirl.create(
        :figure,
        title: 'a figure',
        caption: 'a caption',
        attachment: File.open(Rails.root.join('spec/fixtures/yeti.jpg'))
      )
    end

    it 'adds a figure to a zip' do
      paper.figures = [figure]
      download = DownloadApexZip.new(paper)
      response = download.export

      binding.pry
    end
  end
end
