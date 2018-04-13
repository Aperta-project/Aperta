# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

feature 'Resource Proxy', js: true, vcr: {cassette_name: "attachment", record: :none} do
  let(:file) do
    FactoryGirl.create(:supporting_information_file).tap do |si_file|
      si_file.download!('http://tahi-test.s3.amazonaws.com/temp/bill_ted1.jpg')
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
