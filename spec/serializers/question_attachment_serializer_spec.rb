require 'rails_helper'

describe QuestionAttachmentSerializer do
  subject(:serializer){ QuestionAttachmentSerializer.new(attachment) }
  let(:attachment) do
    FactoryGirl.create(
      :question_attachment,
      title: 'La Attachment',
      attachment: File.open('spec/fixtures/yeti.tiff'),
      status: 'done'
    )
  end

  let(:serialized_content){ serializer.to_json }
  let(:deserialized_content) { JSON.parse serialized_content, symbolize_names: true }

  it 'serializes successfully' do
    expect(deserialized_content).to be_kind_of Hash
  end

  describe 'serialized content' do
    subject(:deserialized_attachment){ deserialized_content[:question_attachment] }

    before do
      expect(attachment.id).to_not be(nil)
      expect(attachment.title).to_not be(nil)
      expect(attachment.src).to_not be(nil)
      expect(attachment.status).to_not be(nil)
      expect(attachment.filename).to_not be(nil)
    end

    it { is_expected.to include(id: attachment.id) }
    it { is_expected.to include(title: attachment.title) }
    it { is_expected.to include(src: attachment.src) }
    it { is_expected.to include(status: attachment.status) }
    it { is_expected.to include(filename: attachment.filename) }
  end

end
