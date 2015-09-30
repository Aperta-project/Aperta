module Snapshot
  class NestedQuestionSerializer < BaseSerializer

    def initialize(nested_question, owner)
      @nested_question = nested_question
      @owner = owner
    end

    def snapshot
      children = []
      @nested_question.children.all.each do |child|
        child_snapshotter = Snapshot::NestedQuestionSerializer.new child, @owner
        children << child_snapshotter.snapshot
      end

      answers_snapshot = []
      answers = @owner.nested_question_answers
                      .select { |q| q.nested_question_id == @nested_question.id }
                      .sort { |a,b| a.id <=> b.id }

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
