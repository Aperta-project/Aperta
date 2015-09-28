module Snapshot
  class AttachmentSerializer < BaseSerializer

    def initialize(attachment)
      @ttachment = attachment
    end

    def snapshot
      if @attachment.nil?
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
