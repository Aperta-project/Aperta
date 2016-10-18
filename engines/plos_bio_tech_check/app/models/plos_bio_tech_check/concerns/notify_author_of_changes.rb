module PlosBioTechCheck
  module NotifyAuthorOfChanges
    extend ActiveSupport::Concern

    def notify_author_of_changes!(submitted_by:)
      update_changes_for_author_task!
      queue_up_emails_for_delivery
      add_user_participations submitted_by
      Activity.task_sent_to_author! self, user: submitted_by
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
        changes_for_author_task = paper.tasks.of_type(
          PlosBioTechCheck::ChangesForAuthorTask
        ).first
        if changes_for_author_task
          changes_for_author_task
        else
          changes_for_author_task = PlosBioTechCheck::ChangesForAuthorTask
            .create!({
              body: {},
              title: PlosBioTechCheck::ChangesForAuthorTask::DEFAULT_TITLE,
              old_role: PlosBioTechCheck::ChangesForAuthorTask::DEFAULT_ROLE,
              paper: paper,
              phase: phase
            })
          changes_for_author_task.add_participant(paper.creator)
          changes_for_author_task.save!
          changes_for_author_task
        end
      end
    end

    def ensure_paper_editable!
      paper.minor_check! unless paper.checking?
    end

    def queue_up_emails_for_delivery
      ChangesForAuthorMailer.delay.notify_changes_for_author(
        author_id: paper.creator.id,
        task_id: changes_for_author_task.id
      )
    end

    def update_changes_for_author_task!
      ensure_paper_editable!
      changes_for_author_task.body['initialTechCheckBody'] = letter_text
      changes_for_author_task.completed = false
      changes_for_author_task.save!
    end
  end
end
