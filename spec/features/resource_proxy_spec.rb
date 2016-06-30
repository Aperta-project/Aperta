require 'rails_helper'

feature 'Resource Proxy', js: true do
  let(:file) do
    FactoryGirl.create \
      :supporting_information_file,
      file: File.open('spec/fixtures/bill_ted1.jpg')
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
      expect(current_url).to match(/
        https:\/\/.*amazonaws.com
        \/uploads
        \/paper
        \/#{file.paper_id}
        \/attachment
        \/#{file.id}
        \/#{file.file_hash}
        \/#{file.filename}
        \?X-Amz-Expires.*\Z
      /x)
    end
  end
end
