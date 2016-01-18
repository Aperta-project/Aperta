require 'rails_helper'

describe S3::FormsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe 'GET #sign' do
    it 'returns url and formData required for a s3 request' do
      get :sign, file_path: 'task/attachment', file_name: 'logo.png',
                 content_type: 'image/png'
      payload = JSON.parse(response.body)
      expect(payload['url']).to eq('http://localhost:31337/fake_s3')
      expect(payload['formData']).to_not be_nil
    end
  end
end
