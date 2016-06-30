require 'rails_helper'

describe Snapshot::AttachmentSerializer do
  subject(:serializer) { described_class.new(attachment) }
  let!(:attachment) do
    FactoryGirl.build_stubbed(
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

  before do
    attachment['file'] = 'yeti.jpg'
  end

  describe '#as_json' do
    it 'serializes to JSON' do
      expect(serializer.as_json).to match hash_including(
        name: 'attachment',
        type: 'properties'
      )

      expect(serializer.as_json[:children]).to match array_including(
        { name: 'id', type: 'integer', value: 1004 },
        { name: 'caption', type: 'text', value: 'attachment 1 caption' },
        { name: 'category', type: 'text', value: 'CategoryOne' },
        { name: 'file', type: 'text', value: 'yeti.jpg' },
        { name: 'file_hash', type: 'text', value: 'abc123' },
        { name: 'label', type: 'text', value: 'Sputnik Records' },
        { name: 'publishable', type: 'boolean', value: true },
        { name: 'status', type: 'text', value: 'processing' },
        { name: 'title', type: 'text', value: 'attachment 1 title' },
        { name: 'url', type: 'url', value: attachment.non_expiring_proxy_url }
      )
    end

    context 'when the attachment CanBeStrikingImage' do
      before { attachment.extend CanBeStrikingImage }

      it 'includes the striking_image' do
        expect(serializer.as_json[:children]).to match array_including(
          { name: 'striking_image', type: 'boolean', value: false }
        )
      end
    end
  end
end
