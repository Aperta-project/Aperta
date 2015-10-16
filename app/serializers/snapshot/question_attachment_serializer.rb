class Snapshot::QuestionAttachmentSerializer < Snapshot::BaseSerializer
  def initialize(question_attachment)
    @question_attachment = question_attachment
  end

  def snapshot
    if @question_attachment.nil?
      return nil
    end

    {
      file: @question_attachment[:attachment],
      title: @question_attachment[:title],
      caption: @question_attachment[:caption],
      status: @question_attachment[:status]
    }
  end
end
