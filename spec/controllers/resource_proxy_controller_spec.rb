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

describe ResourceProxyController do
  let(:example_token) { 'proxy_token' }
  let(:resource_url) { 'https://example.com/some/s3/key' }
  let(:resource_token) do
    FactoryGirl.build_stubbed(:resource_token, owner: attachment)
  end
  let(:attachment) { FactoryGirl.build_stubbed :attachment }

  before do
    allow(ResourceToken).to receive(:find_by!)
      .with(token: example_token)
      .and_return resource_token
    allow(resource_token).to receive(:url).and_return resource_url
  end

  describe 'GET #url without version' do
    subject do
      get :url, resource: :supporting_information_files, token: example_token
    end

    it 'redirects to the ResourceToken#url' do
      expect(subject).to redirect_to(resource_url)
    end
  end

  describe 'GET #url with version' do
    subject do
      get(
        :url,
        resource: :supporting_information_files,
        token: example_token,
        version: 'preview'
      )
    end
    let(:preview_url) { 'https://example.com/s3/key/preview' }

    before do
      allow(resource_token).to receive(:url)
        .with('preview')
        .and_return preview_url
    end

    it 'redirects to the ResourceToken#url(version)' do
      expect(subject).to redirect_to(preview_url)
    end
  end

  describe 'GET #url with non-existent token' do
    subject do
      get(
        :url,
        resource: :supporting_information_files,
        token: example_token
      )
    end

    before do
      allow(ResourceToken).to receive(:find_by!)
        .with(token: example_token)
        .and_raise ActiveRecord::RecordNotFound
    end

    it 'returns an HTTP 404' do
      expect(subject.status).to eq 404
    end
  end

  describe 'GET #url with a good token, but non-existent version' do
    subject do
      get(:url,
        resource: :supporting_information_files,
        token: example_token,
        version: :bogus_version
      )
    end

    before do
      allow(resource_token).to receive(:url).and_return nil
    end

    it 'returns an HTTP 404' do
      expect(ResourceToken).to receive(:find_by!)
        .with(token: example_token)
        .and_return resource_token
      expect(subject.status).to eq 404
    end
  end
end
