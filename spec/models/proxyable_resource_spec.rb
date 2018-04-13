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

describe ProxyableResource, redis: true do
  subject(:file) do
    with_aws_cassette 'supporting_info_files_controller' do
      # SupportingInformationFile includes ProxyableResource
      FactoryGirl.create(
        :supporting_information_file,
        :with_resource_token,
        file: File.open('spec/fixtures/yeti.tiff')
      )
    end
  end
  let(:token) { file.resource_token.token }

  describe '#non_expiring_proxy_url' do
    it 'returns full path when requested' do
      url = "http://www.example.com/resource_proxy/#{token}"
      expect(file.non_expiring_proxy_url(only_path: false)).to eq(url)
    end

    it 'returns relative path by default to the proper route without a version' do
      url = "/resource_proxy/#{token}"
      expect(file.non_expiring_proxy_url).to eq(url)
    end

    it 'returns relative path by default to the proper route WITH a version' do
      url = "/resource_proxy/#{token}/detail"
      expect(file.non_expiring_proxy_url(version: :detail)).to eq(url)
    end

    it 'returns full path when requested with version' do
      url = "http://www.example.com/resource_proxy/#{token}/detail"
      expect(file.non_expiring_proxy_url(only_path: false, version: :detail)).to eq(url)
    end
  end

  describe '#proxyable_url' do
    context 'without version' do
      it 'returns relative url by default when proxy requested' do
        url = "/resource_proxy/#{token}"
        expect(file.proxyable_url(is_proxied: true)).to eq(url)
      end

      it 'returns full url when proxy requested, and only_path is false' do
        url = "http://www.example.com/resource_proxy/#{token}"
        expect(file.proxyable_url(is_proxied: true, only_path: false)).to eq(url)
      end

      it 'returns immediate aws url when requested' do
        expect(file.proxyable_url(is_proxied: false).include?('aws')).to eq(true)
      end
    end

    context 'with version' do
      it 'returns proxied url when requested with version' do
        url = "/resource_proxy/#{token}/detail"
        expect(file.proxyable_url(version: :detail, is_proxied: true)).to eq(url)
      end

      it 'returns immediate aws url when requested with version' do
        expect(file.proxyable_url(version: :detail, is_proxied: false)).to include('detail_')
      end
    end
  end
end
