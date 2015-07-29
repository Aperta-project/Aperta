require "rails_helper"

describe AttachmentSerializer do
  subject(:serializer){ AttachmentSerializer.new(attachment) }
  let(:attachment) { FactoryGirl.create :attachment, :with_task }

  let(:serialized_content){ serializer.to_json }
  let(:deserialized_content) { JSON.parse serialized_content, symbolize_names: true }

  it "serializes successfully" do
    expect(deserialized_content).to be_kind_of Hash
  end

  describe "serialized content" do
    subject(:deserialized_attachment){ deserialized_content[:attachment] }

    it { should include(id: attachment.id) }
    it { should include(title: attachment.title) }
    it { should include(caption: attachment.caption) }
    it { should include(kind: attachment.kind) }
    it { should include(src: attachment.file.url) }
    it { should include(status: attachment.status) }

    it { should include(task_id: attachment.task_id)}

    context "and the attachment is an image" do
      before do
        attachment.update_attributes file: ::File.open('spec/fixtures/yeti.tiff')
      end

      it "has :preview_src" do
        expect(deserialized_attachment[:preview_src]).to match(/http.*yeti.png/)
      end
    end

    context "and the attachment is not an image" do
      it { should include(preview_src: nil) }
    end

    it { should include(filename: attachment.filename) }
  end

end
