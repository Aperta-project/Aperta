module Snapshot
  class NestedQuestionSerializer < BaseSerializer

    def initialize(nested_question, owner)
      @nested_question_id = nested_question.id
      @nested_question = NestedQuestion.find(nested_question.id)
      @owner = owner
    end

    def snapshot
      children = []
      @nested_question.children.all.each do |child|
        child_snapshotter = Snapshot::NestedQuestionSerializer.new nested_question: child, owner: @nested_question
        children << child_snapshotter.snapshot
      end

      answers_snapshot = []
      answers = NestedQuestionAnswer.where(
        nested_question_id: @nested_question_id,
        owner_id: @owner.id,
        owner_type: @owner.class.sti_name).order('id')

      # TODOMPM - this might be overkill.  The structure supports multiple
      # answers to a given question in a given owner, but we don't use that at The
      # moment
      if answers
        answers.each do |answer|
          answer_snapshotter = Snapshot::NestedQuestionAnswerSerializer.new answer
          answers_snapshot << answer_snapshotter.snapshot
        end
      end

      {
        text: @nested_question.text,
        value_type: @nested_question.value_type,
        answers: answers_snapshot,
        children: children
      }
    end
  end
end
