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

describe Snapshot::AttachmentSerializer do
  subject(:serializer) { described_class.new(attachment) }
  let!(:attachment) do
    FactoryGirl.create(
      :attachment,
      :with_resource_token,
      caption: 'attachment 1 caption',
      category: 'CategoryOne',
      file_hash: 'abc123',
      label: 'Sputnik Records',
      owner: paper,
      paper: paper,
      publishable: true,
      status: 'processing',
      title: 'attachment 1 title'
    )
  end
  let(:paper) { FactoryGirl.build_stubbed(:paper) }

  describe '#as_json' do
    before { attachment.public_resource = true }

    it 'serializes to JSON' do
      expect(serializer.as_json).to match hash_including(
        name: 'attachment',
        type: 'properties'
      )

      expect(serializer.as_json[:children]).to match array_including(
        { name: 'id', type: 'integer', value: attachment.id },
        { name: 'caption', type: 'text', value: attachment.caption },
        { name: 'category', type: 'text', value: attachment.category },
        { name: 'file', type: 'text', value: attachment.filename },
        { name: 'file_hash', type: 'text', value: attachment.file_hash },
        { name: 'label', type: 'text', value: attachment.label },
        { name: 'publishable', type: 'boolean', value: attachment.publishable },
        { name: 'status', type: 'text', value: attachment.status },
        { name: 'title', type: 'text', value: attachment.title },
        { name: 'url', type: 'url', value: attachment.non_expiring_proxy_url }
      )
    end
  end
end
