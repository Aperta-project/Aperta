module PlosBioTechCheck
  class FinalTechCheckTask < Task

    DEFAULT_TITLE = 'Final Tech Check'
    DEFAULT_ROLE = 'editor'

    before_create :initialize_body

    def active_model_serializer
      FinalTechCheckTaskSerializer
    end

    def notify_changes_for_author
      PlosBioTechCheck::ChangesForAuthorMailer.delay.notify_changes_for_author(
        author_id: paper.creator.id,
        task_id: self.changes_for_author_task.id
      )
    end

    def changes_for_author_task
      @_task ||= paper.tasks.detect { |task|
                task.type == "PlosBioTechCheck::ChangesForAuthorTask"
              }
      return @_task if @_task.present?

      @_task = PlosBioTechCheck::ChangesForAuthorTask.create!({
        body: {},
        title: PlosBioTechCheck::ChangesForAuthorTask::DEFAULT_TITLE,
        old_role: PlosBioTechCheck::ChangesForAuthorTask::DEFAULT_ROLE,
        paper: paper,
        phase: phase
      })
    end

    def self.nested_questions
      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

    private

    def initialize_body
      self.body = {}
    end
  end
end
