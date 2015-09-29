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

    it { is_expected.to include(id: attachment.id) }
    it { is_expected.to include(title: attachment.title) }
    it { is_expected.to include(caption: attachment.caption) }
    it { is_expected.to include(kind: attachment.kind) }
    it { is_expected.to include(src: attachment.file.url) }
    it { is_expected.to include(status: attachment.status) }

    it { is_expected.to include(task: { id: attachment.task.id, type: "Task" })}

    context "and the attachment is an image" do
      before do
        attachment.update_attributes file: ::File.open('spec/fixtures/yeti.tiff')
      end

      it "has :preview_src" do
        expect(deserialized_attachment[:preview_src]).to match(/\/preview_yeti.png/)
      end

      it "has :detail_src" do
        expect(deserialized_attachment[:detail_src]).to match(/\/detail_yeti.png/)
      end
    end

    context "and the attachment is not an image" do
      it { is_expected.to include(preview_src: nil) }
      it { is_expected.to include(detail_src: nil) }
    end

    it { is_expected.to include(filename: attachment.filename) }
  end

end
