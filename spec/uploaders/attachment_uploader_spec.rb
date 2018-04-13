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

describe AttachmentUploader do
  it_behaves_like 'AttachmentUploader: standard attachment image transcoding'
  it_behaves_like 'AttachmentUploader: standard attachment image resizing'

  describe '#store_dir' do
    let(:uploader) { described_class.new(model, :attachment) }
    let(:model) do
      FactoryGirl.build_stubbed(
        :attachment,
        id: 99,
        file_hash: 'abc123',
        paper_id: 11
      )
    end

    context 'when the model responds to :s3_dir, but has no s3_dir value' do
      before { model.s3_dir = nil }

      it 'returns a computed value' do
        expect(uploader.store_dir).to eq \
          "uploads/paper/11/attachment/99/#{model.file_hash}"
      end
    end

    context 'when the model has a cached s3_dir' do
      before { model.s3_dir = 'some/cached/path' }

      it 'returns the cached s3_dir' do
        expect(uploader.store_dir).to eq('some/cached/path')
      end
    end

    context 'when the model does not respond_to :s3_dir' do
      let(:model) { double('model', id: 1, paper_id: 11, file_hash: 'def987')}

      it 'returns a computed value' do
        expect(uploader.store_dir).to eq \
          "uploads/paper/11/attachment/1/#{model.file_hash}"
      end
    end
  end
end
