class Snapshot::BaseTaskSerializer < Snapshot::BaseSerializer
  attr_reader :task

  def initialize(task)
    @task = task
  end

  def as_json
    properties = snapshot_properties
    if properties
      properties + snapshot_nested_questions
    else
      snapshot_nested_questions
    end
  end

  def snapshot_properties
  end

  def snapshot_nested_questions
    return [] unless @task.nested_questions.any?
    nested_questions_snapshot = []
    @task.nested_questions.select {|q| q.parent_id.nil? }.each do |nested_question|
      nested_question_serializer = Snapshot::NestedQuestionSerializer.new nested_question, @task
      nested_questions_snapshot << nested_question_serializer.as_json
    end

    nested_questions_snapshot
  end

end
