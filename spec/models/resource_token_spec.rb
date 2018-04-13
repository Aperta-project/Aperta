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

describe ResourceToken do

  describe '#url' do
    subject(:resource_token) do
      FactoryGirl.build_stubbed(
        :resource_token,
        default_url: 'yeti.jpg',
        owner_type: 'Attachment',
        owner_id: 99,
        version_urls: {
          preview: 'preview.jpg',
          detail: 'details.jpg'
        }
      )
    end

    before do
      allow(Attachment).to receive(:authenticated_url_for_key) do |url|
        "https://u-been-authed.com/#{url}"
      end
    end

    it <<-DESC.strip_heredoc do
      asks the owner_type to build an authenticated URL.
      This is so ResourceToken can rely on knowledge that the owner of the
      ResourceToken already has such as S3 configuration, signing, etc.
    DESC
      expect(Attachment).to receive(:authenticated_url_for_key)
      resource_token.url
    end

    context 'and no version is provided' do
      it 'returns an authenticated url for the default_url' do
        expect(resource_token.url).to \
          eq('https://u-been-authed.com/yeti.jpg')
      end
    end

    context 'and a nil version is provided for the default_url' do
      it <<-DESC.strip_heredoc do
        returns an authenticated url for the default_url.
        This is for API convenience for the caller.
      DESC
        expect(resource_token.url(nil)).to \
          eq('https://u-been-authed.com/yeti.jpg')
      end
    end

    context 'and a version is provided as a Symbol' do
      it 'returns an authenticated url for the versioned url' do
        expect(resource_token.url(:preview)).to \
          eq('https://u-been-authed.com/preview.jpg')

        expect(resource_token.url(:detail)).to \
          eq('https://u-been-authed.com/details.jpg')
      end
    end

    context 'and a version is provided as a String' do
      it 'returns an authenticated url for the versioned url' do
        expect(resource_token.url('preview')).to \
          eq('https://u-been-authed.com/preview.jpg')

        expect(resource_token.url('detail')).to \
          eq('https://u-been-authed.com/details.jpg')
      end
    end

    context 'and a non-existent version is provided' do
      it 'returns nil' do
        expect(resource_token.url(:bogus_version)).to be(nil)
      end
    end
  end
end
