require 'rails_helper'

describe QuestionAttachmentSerializer, serializer_test: true do
  subject(:attachment) do
    FactoryGirl.create(
      :question_attachment,
      title: 'La Attachment',
      attachment: File.open('spec/fixtures/yeti.tiff'),
      status: 'done'
    )
  end

  it 'should serialize succesfully' do
    expect(attachment.id).to_not be(nil)
    expect(attachment.title).to_not be(nil)
    expect(attachment.src).to_not be(nil)
    expect(attachment.status).to_not be(nil)
    expect(attachment.filename).to_not be(nil)

    expect(deserialized_content)
      .to match(
        hash_including(
          question_attachment:
            hash_including(
              id: attachment.id,
              title: attachment.title,
              src: attachment.src,
              status: attachment.status,
              filename: attachment.filename)))
  end
end
