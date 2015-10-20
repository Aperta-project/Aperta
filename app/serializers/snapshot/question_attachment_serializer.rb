class Snapshot::QuestionAttachmentSerializer < Snapshot::BaseSerializer
  def initialize(question_attachment)
    @question_attachment = question_attachment
  end

  def snapshot
    if @question_attachment.nil?
      return nil
    end
    
    {
      name: "attachment",
      type: "properties",
      children: [
        snapshot_property("file", "text", @question_attachment[:attachment]),
        snapshot_property("title", "text", @question_attachment[:title]),
        snapshot_property("caption", "text", @question_attachment[:caption]),
        snapshot_property("status", "text", @question_attachment[:status])
      ]
    }
  end
end
