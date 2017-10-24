require "rails_helper"

describe AdhocAttachmentSerializer, serializer_test: true do
  let(:attachment) do
    FactoryGirl.create(
      :adhoc_attachment,
      :with_task,
      :with_resource_token,
      status: AdhocAttachment::STATUS_DONE,
    )
  end
  let(:token) { attachment.token }
  let(:object_for_serializer) { attachment }
  let(:src) do
    "/resource_proxy/" + token
  end

  it "serializes successfully" do
    expect(deserialized_content).to be_kind_of Hash
  end

  describe "serialized content" do
    it 'includes the data we expect' do
      expected_contents = hash_including(
        id: attachment.id,
        title: attachment.title,
        caption: attachment.caption,
        file_type: attachment.file_type,
        src: src,
        status: attachment.status,
        filename: attachment.filename,
        task: { id: attachment.task.id, type: "ad-hoc-task" },
        type: 'AdhocAttachment'
      )
      expect(deserialized_content[:adhoc_attachment]).to match(expected_contents)
    end
  end

  context "and the attachment is an image" do
    before do
      attachment.update_attributes file: ::File.open('spec/fixtures/yeti.tiff')
    end

    it "has :preview_src & :detail_sec" do
      expect(deserialized_content)
        .to match(hash_including(
                    adhoc_attachment: hash_including(
                      preview_src: src + "/preview",
                      detail_src: src + "/detail")))
    end
  end

  context "and the attachment is not an image" do
    before do
      attachment.update_attributes file: ::File.open('spec/fixtures/blah.zip')
    end

    it "has empty :preview_src & :detail_sec" do
      expect(deserialized_content)
        .to match(hash_including(
                    adhoc_attachment: hash_including(
                      preview_src: nil,
                      detail_src: nil)))
    end
  end
end
