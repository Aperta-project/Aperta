require "rails_helper"

describe AttachmentSerializer, serializer_test: true do
  let(:attachment) { FactoryGirl.create :attachment, :with_task }
  let(:object_for_serializer) { attachment }

  it "serializes successfully" do
    expect(deserialized_content).to be_kind_of Hash
  end

  describe "serialized content" do
    it 'includes the data we expect' do
      expect(deserialized_content)
        .to match(hash_including(attachment:
                                   hash_including(
                                     id: attachment.id,
                                     title: attachment.title,
                                     caption: attachment.caption,
                                     kind: attachment.kind,
                                     src: attachment.file.url,
                                     status: attachment.status,
                                     filename: attachment.filename,
                                     task: { id: attachment.task.id, type: "Task" })))
    end
  end

  context "and the attachment is an image" do
    before do
      attachment.update_attributes file: ::File.open('spec/fixtures/yeti.tiff')
    end

    it "has :preview_src & :detail_sec" do
      expect(deserialized_content)
        .to match(hash_including(
                    attachment: hash_including(
                      preview_src: %r{/preview_yeti.png},
                      detail_src: %r{/detail_yeti.png})))
    end
  end

  context "and the attachment is not an image" do
    it "has empty :preview_src & :detail_sec" do
      expect(deserialized_content)
        .to match(hash_including(
                    attachment: hash_including(
                      preview_src: nil,
                      detail_src: nil)))
    end
  end
end
