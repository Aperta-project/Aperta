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

    context 'when the attachment CanBeStrikingImage' do
      before { attachment.extend CanBeStrikingImage }

      it 'includes the striking_image' do
        expect(serializer.as_json[:children]).to match array_including(
          { name: 'striking_image', type: 'boolean', value: attachment.striking_image }
        )
      end
    end
  end
end
