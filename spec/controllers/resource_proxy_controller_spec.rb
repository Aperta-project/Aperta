require 'rails_helper'

describe ResourceProxyController do
  let(:example_token) { 'proxy_token' }
  let(:aws_url) { 'https://awsurl.example.com' }

  describe 'GET #url without version' do
    let(:attachment_double) { double }
    subject do
      get :url, resource: :supporting_information_files, token: example_token
    end

    it 'redirects to S3 URL for unversioned resources' do
      allow(attachment_double).to receive_message_chain(:owner, :file, :url) { aws_url }
      allow(ResourceToken).to receive(:find_by!).with(token: example_token) { attachment_double }
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
        expect(url_double).to receive(:url).with('preview') { aws_url }
        allow(attachment_double).to receive_message_chain(:owner, :file) { url_double }
        allow(ResourceToken).to receive(:find_by!).with(token: example_token) { attachment_double }
        expect(subject).to redirect_to(aws_url)
      end
    end

    describe 'detail version' do
      let(:version) { :detail }
      it 'redirects to S3 URL for preview version resources' do
        expect(url_double).to receive(:url).with('detail') { aws_url }
        allow(attachment_double).to receive_message_chain(:owner, :file) { url_double }
        allow(ResourceToken).to receive(:find_by!).with(token: example_token) { attachment_double }
        expect(subject).to redirect_to(aws_url)
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

    it 'is not found' do
      expect(ResourceToken).to receive(:find_by!).with(token: example_token) { fail ActiveRecord::RecordNotFound }
      expect(subject.status).to eq 404
    end
  end
end
