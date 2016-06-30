require 'rails_helper'

describe AttachmentUploader do
  include_examples 'standard attachment image transcoding'
  include_examples 'standard attachment image resizing'

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
