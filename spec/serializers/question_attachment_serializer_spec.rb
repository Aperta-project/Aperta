require 'rails_helper'

describe QuestionAttachmentSerializer, serializer_test: true do
  let(:attachment) do
    FactoryGirl.create(
      :question_attachment,
      :with_resource_token,
      title_html: 'La Attachment',
      file: File.open('spec/fixtures/yeti.tiff'),
      status: QuestionAttachment::STATUS_DONE
    )
  end
  let(:object_for_serializer) { attachment }

  it 'should serialize succesfully' do
    expect(attachment.id).to_not be(nil)
    expect(attachment.title_html).to_not be(nil)
    expect(attachment.src).to_not be(nil)
    expect(attachment.status).to_not be(nil)
    expect(attachment.filename).to_not be(nil)

    expect(deserialized_content)
      .to match(
        hash_including(
          question_attachment:
            hash_including(
              id: attachment.id,
              title_html: attachment.title_html,
              src: attachment.src,
              status: attachment.status,
              filename: attachment.filename
            )
        )
      )
  end
end
