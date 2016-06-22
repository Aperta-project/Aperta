require 'rails_helper'

describe ResourceProxyController do
  subject(:file) do
    with_aws_cassette('supporting_info_file') do
      FactoryGirl.create(
        :supporting_information_file,
        file: File.open('spec/fixtures/yeti.tiff'),
        status: SupportingInformationFile::STATUS_DONE
      )
    end
  end

  describe 'GET #url without version' do
    subject do
      get :url, resource: :supporting_information_files, token: file.token
    end

    it 'redirects to S3 URL for supporting_information_files' do
      subject
      target = file.file.url
      expect(subject).to redirect_to(target)
      expect(target).to include('amazonaws')
      expect(target).to include(file.filename)
    end
  end

  describe 'GET #url with version' do
    subject do
      get :url,
          resource: :supporting_information_files,
          token: file.token,
          version: :preview
    end

    it 'redirects to S3 URL for supporting_information_files' do
      subject
      target = file.file.url(:preview)
      expect(subject).to redirect_to(target)
      expect(target).to include('amazonaws')
      # for versions, they are converted to png: yeti.tiff => preview_yeti.png
      expect(target).to include("preview_#{file.filename.split('.').first}.png")
    end
  end

  describe 'GET #url with bad (never generated) token' do
    subject do
      get :url,
          resource: :supporting_information_files,
          token: 'faketoken',
          version: :preview
    end

    it 'is not found' do
      expect(file)
      expect(subject.status).to eq 404
    end
  end

  describe 'GET #url with old token' do
    it 'is not found' do
      expect(file.token).to be_truthy
      old_token = file.token
      file.regenerate_token
      expect(file.token).not_to eq(old_token)

      get :url,
          resource: :supporting_information_files,
          token: old_token

      expect(response.status).to eq 404

      get :url,
          resource: :supporting_information_files,
          token: file.token

      target = file.file.url
      expect(response).to redirect_to(target)
    end
  end

  describe 'GET #url with resouce not in whitelist' do
    it 'redirects to S3 URL for supporting_information_files' do
      expect { get :url, resource: :protected_resource, token: file.token }
        .to raise_error(ActionController::RoutingError)
    end
  end
end
