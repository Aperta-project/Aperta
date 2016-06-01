module TahiStandardTasks
  class ReviseTask < Task
    include SubmissionTask

    DEFAULT_TITLE = 'Revise Manuscript'
    DEFAULT_ROLE = 'author'

    def active_model_serializer
      ReviseTaskSerializer
    end

    def self.setup_new_revision(paper, phase)
      paper.notify_requester = true
      paper.editable = true
      paper.decisions.create(notify_requester: true)
      paper.save!

      existing_revise_task = find_by(paper: paper)
      if existing_revise_task
        existing_revise_task.update(completed: false, phase: phase)
      else
        TaskFactory.create(self, paper: paper, phase: phase)
      end
    end
  end
end
