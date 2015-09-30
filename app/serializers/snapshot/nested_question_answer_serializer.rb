module Snapshot
  class NestedQuestionAnswerSerializer < BaseSerializer

    def initialize(nested_question_answer)
      @nested_question_answer = nested_question_answer
    end

    def snapshot
      attachment = QuestionAttachment.select { |qa| qa.question_id == @nested_question_answer.id }.first
      attachment_snapshotter = Snapshot::QuestionAttachmentSerializer.new attachment

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
