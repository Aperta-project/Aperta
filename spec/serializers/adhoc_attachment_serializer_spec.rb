require "rails_helper"

describe AdhocAttachmentSerializer, serializer_test: true do
  let(:attachment) do
    FactoryGirl.create(
      :adhoc_attachment,
      :with_task,
      status: AdhocAttachment::STATUS_DONE,
      token: token
    )
  end
  let(:token) { 'hfrrpwV1VHYb7x2T' }
  let(:object_for_serializer) { attachment }
  let(:src) do
    "/resource_proxy/adhoc_attachments/" + token
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
        kind: attachment.kind,
        src: src,
        status: attachment.status,
        filename: attachment.filename,
        task: { id: attachment.task.id, type: "Task" },
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
    it "has empty :preview_src & :detail_sec" do
      expect(deserialized_content)
        .to match(hash_including(
                    adhoc_attachment: hash_including(
                      preview_src: nil,
                      detail_src: nil)))
    end
  end
end
