module PlosBioTechCheck
  class NotifyAuthorOfChangesNeededService
    attr_reader :submitted_by, :task

    def initialize(task, submitted_by:)
      @task = task
      @submitted_by = submitted_by
    end

    def notify!
      update_changes_for_author_task!
      queue_up_email_for_delivery
      add_user_participations submitted_by
      Activity.task_sent_to_author! task, user: submitted_by
    end

    private

    def add_user_participations(submitted_by)
      users = [submitted_by] + paper.collaborators
      users.each do |user|
        changes_for_author_task.add_participant(user)
      end
    end

    def changes_for_author_task
      @changes_for_author_task ||= begin
        paper.tasks.of_type(ChangesForAuthorTask).first ||
          create_changes_for_author_task
      end
    end

    def create_changes_for_author_task
      ChangesForAuthorTask.create!({
        body: {},
        title: ChangesForAuthorTask::DEFAULT_TITLE,
        old_role: ChangesForAuthorTask::DEFAULT_ROLE,
        paper: paper,
        phase: task.phase
      }).tap do |changes_for_author_task|
        changes_for_author_task.add_participant(paper.creator)
        changes_for_author_task.save!
      end
    end

    def ensure_paper_editable!
      paper.minor_check! unless paper.checking?
    end

    def paper
      @task.paper
    end

    def queue_up_email_for_delivery
      ChangesForAuthorMailer.delay.notify_changes_for_author(
        author_id: paper.creator.id,
        task_id: changes_for_author_task.id
      )
    end

    def update_changes_for_author_task!
      ensure_paper_editable!
      changes_for_author_task.body['initialTechCheckBody'] = task.letter_text
      changes_for_author_task.completed = false
      changes_for_author_task.save!
    end
  end
end
