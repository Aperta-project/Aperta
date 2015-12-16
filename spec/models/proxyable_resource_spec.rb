require 'rails_helper'

describe ProxyableResource, redis: true do
  let(:paper) { FactoryGirl.create :paper }
  let(:file) do
    with_aws_cassette 'supporting_info_files_controller' do
      # SupportingInformationFile includes ProxyableResource
      paper.supporting_information_files.create! attachment: ::File.open('spec/fixtures/yeti.tiff')
    end
  end

  describe '#non_expiring_proxy_url' do
    it 'returns path only by default' do
      url = "/resource_proxy/supporting_information_files/#{file.token}"
      expect(file.non_expiring_proxy_url).to eq(url)
    end

    it 'returns full path when requested' do
      url = "http://www.example.com/resource_proxy/supporting_information_files/#{file.token}"
      expect(file.non_expiring_proxy_url(only_path: false)).to eq(url)
    end

    it 'returns relative path by default to the proper route without a version' do
      url = "/resource_proxy/supporting_information_files/#{file.token}"
      expect(file.non_expiring_proxy_url).to eq(url)
    end

    it 'returns relative path by default to the proper route WITH a version' do
      url = "/resource_proxy/supporting_information_files/#{file.token}/detail"
      expect(file.non_expiring_proxy_url(version: :detail)).to eq(url)
    end

    it 'returns full path when requested with version' do
      url = "http://www.example.com/resource_proxy/supporting_information_files/#{file.token}/detail"
      expect(file.non_expiring_proxy_url(only_path: false, version: :detail)).to eq(url)
    end
  end
  describe '#proxyable_url' do
    context 'without version' do
      it 'returns relative url by default when proxy requested' do
        url = "/resource_proxy/supporting_information_files/#{file.token}"
        expect(file.proxyable_url(is_proxied: true)).to eq(url)
      end

      it 'returns full url when proxy requested, and only_path is false' do
        url = "http://www.example.com/resource_proxy/supporting_information_files/#{file.token}"
        expect(file.proxyable_url(is_proxied: true, only_path: false)).to eq(url)
      end

      it 'returns immediate aws url when requested' do
        expect(file.proxyable_url(is_proxied: false).include?('aws')).to eq(true)
      end
    end

    context 'with version' do
      it 'returns proxied url when requested with version' do
        url = "/resource_proxy/supporting_information_files/#{file.token}/detail"
        expect(file.proxyable_url(version: :detail, is_proxied: true)).to eq(url)
      end

      it 'returns immediate aws url when requested with version' do
        expect(file.proxyable_url(version: :detail, is_proxied: false)).to include('detail_')
      end
    end
  end
end
