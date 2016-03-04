require 'rails_helper'

feature 'Resource Proxy', js: true do
  let(:file) do
    with_aws_cassette('supporting_info_file') do
      FactoryGirl.create :supporting_information_file,
                         attachment: File.open('spec/fixtures/yeti.tiff'),
                         status: 'done'
    end
  end

  describe 'GET #url without version' do
    let(:url) do
      url_for(controller: :resource_proxy,
              action: :url,
              resource: 'supporting_info_file',
              token: file.token)
    end

    it 'redirects to S3 URL for supporting_information_files' do
      visit("/resource_proxy/supporting_information_files/#{file.token}")
      expect(current_url).to match(%r{\Ahttps://.*.amazonaws\.com/uploads/attachments/[0-9]+/supporting_information_file/attachment/[0-9]+/yeti\.tiff\?X-Amz-Expires.*\Z})
    end
  end
end
