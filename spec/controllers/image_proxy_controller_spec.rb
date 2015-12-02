require 'rails_helper'

describe ImageProxyController do
  let(:user) { FactoryGirl.create(:user) }
  let(:figure) {
    with_aws_cassette('figure') do
      FactoryGirl.create :figure,
                          attachment: File.open('spec/fixtures/yeti.tiff'),
                          status: 'done'
    end
  }
  before { sign_in user }

  describe 'GET on #show' do
    it 'redirects to S3 URL' do
      get :show, figure_id: figure.id
      expect(figure).to redirect_to(figure.attachment.url)
    end

    it 'redirects to S3 URL with the proper version' do
      get :show, figure_id: figure.id, version: 'preview'
      expect(figure).to redirect_to(figure.attachment.url(:preview))
    end
  end
end
