require 'rails_helper'

describe Attachment do
  describe "#image" do
    let(:attachment) { Attachment.new }

    it "returns true if the file is of type image" do
      file = OpenStruct.new(file: OpenStruct.new(extension: "jpg"))
      expect(attachment).to receive(:file).twice.and_return(file)
      expect(attachment.image?).to eq(true)
    end

    it "returns false if the file is not of type image" do
      file = OpenStruct.new(file: OpenStruct.new(extension: "pdf"))
      expect(attachment).to receive(:file).twice.and_return(file)
      expect(attachment.image?).to eq(false)
    end
  end

  describe "#after_destroy" do
    let(:attachment) { Attachment.create(attachable_id: 1, attachable_type: 'Task')}

    #This after_destroy will enable people to show a "last saved" timestamp on cards,
    #even when an attachment is deleted because it touches the last_updated column of a card.
    it "updates the last_updated date" do
      task = create(:task)
      attachment.destroy
      expect(task.reload.updated_at).to be > (task.reload.created_at)
    end
  end
end
