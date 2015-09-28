module Snapshot
  class BaseTaskSerializer < BaseSerializer
    attr_reader :task

    def initialize(task)
      @task = task
    end

    def snapshot
      task_snapshot = []
      task_snapshot << ["properties", snapshot_properties]
      task_snapshot << ["questions", snapshot_nested_questions]
    end

    def snapshot_properties
    end

    def snapshot_nested_questions
      nested_questions_snapshot = []
      @task.nested_questions.where(parent_id: nil).each do |nested_question|
        nested_question_serializer = Snapshot::NestedQuestionSerializer.new nested_question, @task
        nested_questions_snapshot << nested_question_serializer.snapshot
      end
      nested_questions_snapshot
    end

  end
end
