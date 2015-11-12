module Typesetter
  # Base class for serializers that need to interact
  # with nested question answers.
  class TaskAnswerSerializer < ActiveModel::Serializer
    private

    def tasks_by_type(task_type)
      object.tasks.where(type: task_type)
    end

    def task(task_type)
      t = tasks_by_type(task_type)
      if t.length > 1
        fail Typesetter::MetadataError.multiple_tasks(t)
      elsif t.length == 0
        fail Typesetter::MetadataError.no_task(task_type)
      end
      t.first
    end

    def task_answer_value(task, question_ident)
      answer = task.answer_for(question_ident) if task
      answer.value
    end
  end
end
