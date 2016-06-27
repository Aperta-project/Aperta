require 'rails_helper'

describe AttachmentUploader do
  include_examples 'standard attachment image transcoding'
  include_examples 'standard attachment image resizing'

  describe '#store_dir' do
    let(:uploader) { described_class.new(model, :attachment) }

    context 'when the model has a cached s3_dir' do
      let(:model) { double("attachment_model", s3_dir: 'some/cached/path') }

      it 'returns the cached s3_dir' do
        expect(uploader.store_dir).to eq('some/cached/path')
      end
    end

    context 'when the model does not respond_to :s3_dir' do
      let(:paper) { double('paper', id: 11) }
      let(:model) { double('attachment_model', id: 99, paper: paper) }

      it 'returns a computed value' do
        expect(uploader.store_dir).to eq \
          "uploads/paper/11/#{model.class.to_s.underscore}/attachment/99"
      end
    end

    context 'when the model responds to :s3_dir, but has no s3_dir value' do
      let(:paper) { double('paper', id: 11) }
      let(:model) { double('attachment_model', id: 99, paper: paper) }

      it 'returns a computed value' do
        expect(uploader.store_dir).to eq \
          "uploads/paper/11/#{model.class.to_s.underscore}/attachment/99"
      end
    end
  end
end
