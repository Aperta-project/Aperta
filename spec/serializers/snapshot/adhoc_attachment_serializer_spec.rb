require 'rails_helper'

describe Snapshot::AdhocAttachmentSerializer do
  subject(:serializer) { described_class.new(adhoc_attachment) }
  let!(:adhoc_attachment) do
    FactoryGirl.build_stubbed(
      :adhoc_attachment,
      owner: paper,
      title: 'attachment 1 title',
      caption: 'attachment 1 caption'
    )
  end
  let(:paper) { FactoryGirl.build_stubbed(:paper) }

  before do
    adhoc_attachment['file'] = 'yeti.jpg'
  end

  describe '#as_json' do
    it 'serializes to JSON' do
      expect(serializer.as_json).to eq(
        { name: 'adhoc-attachment', type: 'properties', children: [
          { name: 'id', type: 'integer', value: adhoc_attachment.id },
          { name: 'file', type: 'text', value: 'yeti.jpg' },
          { name: 'file_hash', type: 'text', value: adhoc_attachment.file_hash },
          { name: 'title', type: 'text', value: 'attachment 1 title' }
        ]}
      )
    end
  end
end
