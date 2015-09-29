module Snapshot
  class BaseTaskSerializer < BaseSerializer
    attr_reader :task

    def initialize(task)
      @task = task
    end

    def snapshot
      {
        properties: snapshot_properties,
        questions: snapshot_nested_questions
      }
    end

    def snapshot_properties
    end

    def snapshot_nested_questions
      return [] unless @task.nested_questions.any?
      nested_questions_snapshot = []
      @task.nested_questions.select {|q| q.parent_id.nil? }.each do |nested_question|
        nested_question_serializer = Snapshot::NestedQuestionSerializer.new nested_question, @task
        nested_questions_snapshot << nested_question_serializer.snapshot
      end
      nested_questions_snapshot
    end

  end
end
