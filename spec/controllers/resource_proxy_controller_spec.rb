require 'rails_helper'

describe ResourceProxyController do
  let(:example_token) { 'proxy_token' }
  let(:aws_url) { 'https://awsurl.example.com' }
  let(:preview_url) { 'https://awsurl.example.com/preview' }
  let(:detail_url) { 'https://awsurl.example.com/detail' }
  let(:resource_token) do
    FactoryGirl.build_stubbed :resource_token,
      owner: attachment,
      default_url: aws_url,
      version_urls: {preview: preview_url, detail: detail_url}
  end
  let(:attachment) { FactoryGirl.build_stubbed :attachment }

  describe 'GET #url without version' do
    let(:attachment_double) { double }
    subject do
      get :url, resource: :supporting_information_files, token: example_token
    end

    it 'redirects to S3 URL for unversioned resources' do
      allow(attachment).to receive(:url) { aws_url }
      allow(ResourceToken)
        .to receive(:find_by!)
          .with(token: example_token) { resource_token }

      expect(subject).to redirect_to(aws_url)
    end
  end

  describe 'GET #url with version' do
    let(:attachment_double) { double }
    let(:url_double) { double }
    let(:subject) do
      get :url,
          resource: :supporting_information_files,
          token: example_token,
          version: version
    end

    describe 'preview version' do
      let(:version) { :preview }
      it 'redirects to S3 URL for preview version resources' do
        allow(ResourceToken)
          .to receive(:find_by!)
            .with(token: example_token) { resource_token }
        expect(subject).to redirect_to(preview_url)
      end
    end

    describe 'detail version' do
      let(:version) { :detail }
      it 'redirects to S3 URL for preview version resources' do
        allow(ResourceToken)
          .to receive(:find_by!)
            .with(token: example_token) { resource_token }

        expect(subject).to redirect_to(detail_url)
      end
    end
  end

  describe 'GET #url with non-existant token' do
    subject do
      get :url,
          resource: :supporting_information_files,
          token: example_token,
          version: :preview
    end

    it 'returns an HTTP 404' do
      expect(ResourceToken)
        .to receive(:find_by!)
          .with(token: example_token) { fail ActiveRecord::RecordNotFound }
      expect(subject.status).to eq 404
    end
  end

  describe 'GET #url with a good token, but non-existant version' do
    subject do
      get :url,
          resource: :supporting_information_files,
          token: example_token,
          version: :bogus_version
    end

    it 'returns an HTTP 404' do
      expect(ResourceToken)
        .to receive(:find_by!)
          .with(token: example_token) { resource_token }
      expect(subject.status).to eq 404
    end
  end
end
