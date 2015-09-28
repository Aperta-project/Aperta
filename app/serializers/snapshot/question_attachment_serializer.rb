module Snapshot
  class QuestionAttachmentSerializer < BaseSerializer

    def initialize(question_attachment)
      @question_attachment = question_attachment
    end

    def snapshot
      if @question_attachment.nil?
        return nil
      end

      {
        file: @question_attachment.file,
        title: @question_attachment.title,
        caption: @question_attachment.caption,
        kind: @question_attachment.kind,
        created_at: @question_attachment.created_at,
        updated_at: @question_attachment.updated_at
      }
    end
  end
end
