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
        return
      end
      tasks.first
    end
  end
end
