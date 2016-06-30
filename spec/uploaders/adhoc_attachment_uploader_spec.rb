require 'rails_helper'

describe AdhocAttachmentUploader do
  include_examples 'AttachmentUploader: standard attachment image transcoding'
  include_examples 'AttachmentUploader: standard attachment image resizing'

  describe '#store_dir' do
    let(:uploader) { AdhocAttachmentUploader.new(model, :attachment) }

    context 'when the model has a cached s3_dir' do
      let(:model) { double('attachment_model', s3_dir: 'some/cached/path') }

      it 'returns the cached s3_dir' do
        expect(uploader.store_dir).to eq('some/cached/path')
      end
    end

    context 'when the model does not respond_to :s3_dir' do
      let(:model) { double('attachment_model', id: 99) }

      it 'returns a computed value' do
        expect(uploader.store_dir).to eq \
          "uploads/attachments/#{model.id}/attachment/file/#{model.id}"
      end
    end

    context 'when the model responds to :s3_dir, but has no s3_dir value' do
      let(:model) { double('attachment_model', id: 99, s3_dir: nil) }

      it 'returns a computed value' do
        expect(uploader.store_dir).to eq \
          "uploads/attachments/#{model.id}/attachment/file/#{model.id}"
      end
    end
  end
end
