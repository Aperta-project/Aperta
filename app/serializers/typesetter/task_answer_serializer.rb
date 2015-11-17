module Typesetter
  # Base class for serializers that need to interact
  # with nested question answers.
  class TaskAnswerSerializer < ActiveModel::Serializer
    private

    def tasks_by_type(task_type)
      object.tasks.where(type: task_type)
    end

    def task(task_type)
      tasks = tasks_by_type(task_type)
      if tasks.length > 1
        fail Typesetter::MetadataError.multiple_tasks(tasks)
      elsif tasks.length == 0
        fail Typesetter::MetadataError.no_task(task_type)
      end
      tasks.first
    end

    def task_answer_value(task, question_ident)
      answer = task.answer_for(question_ident) if task
      answer.value if answer
    end
  end
end
