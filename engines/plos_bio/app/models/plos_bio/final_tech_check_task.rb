module PlosBio
  class FinalTechCheckTask < Task

    register_task default_title: 'Final Tech Check', default_role: 'editor'

    def active_model_serializer
      FinalTechCheckTaskSerializer
    end

    def notify_changes_for_author
      PlosBio::ChangesForAuthorMailer.delay.notify_changes_for_author(
        author_id: paper.creator.id,
        task_id: self.changes_for_author_task.id
      )
    end

    def changes_for_author_task
      @_task ||= paper.tasks.detect { |task|
                task.type == "PlosBio::ChangesForAuthorTask"
              }
      return @_task if @_task.present?

      task_properties = TaskType.types["PlosBio::ChangesForAuthorTask"]
      @_task = PlosBio::ChangesForAuthorTask.create!({
        body: {},
        title: task_properties[:default_title],
        old_role: task_properties[:default_role],
        paper: paper,
        phase: phase
      })
    end

    def self.nested_questions
      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end
  end
end
