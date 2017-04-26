module TahiStandardTasks
  class ReviseTask < Task
    include SubmissionTask

    DEFAULT_TITLE = 'Response to Reviewers'.freeze
    DEFAULT_ROLE_HINT = 'author'.freeze
    SYSTEM_GENERATED = true

    def active_model_serializer
      ReviseTaskSerializer
    end

    def self.setup_new_revision(paper, phase)
      existing_revise_task = find_by(paper: paper)
      if existing_revise_task
        existing_revise_task.update(completed: false, phase: phase)
      else
        TaskFactory.create(self,
                           paper: paper,
                           phase: phase,
                           card_version: latest_card_version)
      end
    end
  end
end
