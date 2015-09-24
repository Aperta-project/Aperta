module Snapshot
  class NestedQuestionAnswerSerializer < BaseSerializer

    def initialize(nested_question_answer)
      @nested_question_answer = NestedQuestionAnswer.includes(:attachment).find(nested_question_answer.id)
    end

    def snapshot
      attachment_snapshotter = Snapshot::QuestionAttachmentSerializer.new @nested_question_answer.attachment

      {
        value: @nested_question_answer.value,
        additional_data: @nested_question_answer.additional_data,
        attachment: attachment_snapshotter.snapshot,
        created_at: @nested_question_answer.created_at,
        updated_at: @nested_question_answer.updated_at
      }
    end
  end
end
