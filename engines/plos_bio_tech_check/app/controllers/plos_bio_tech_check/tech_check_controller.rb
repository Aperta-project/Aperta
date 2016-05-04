module PlosBioTechCheck
  module TechCheckController
    def send_email
      update_changes_for_author_task!(task, letter_text(task))
      task.notify_changes_for_author
      add_user_participations current_user
      Activity.task_sent_to_author! task, user: current_user
      render json: { success: true }
    end

    def update_changes_for_author_task!(task, text)
      ensure_paper_editable!
      changes_for_author_task = task.changes_for_author_task
      changes_for_author_task.body['initialTechCheckBody'] = text
      changes_for_author_task.completed = false
      changes_for_author_task.save!
    end

    def add_user_participations(editor_user)
      users = [editor_user] + task.paper.collaborators
      users.each do |user|
        task.changes_for_author_task.add_participant(user)
      end
    end

    private

    def task
      @task ||= Task.find(params[:id])
    end

    def ensure_paper_editable!
      return if task.paper.unsubmitted? || task.paper.checking?
      task.paper.minor_check!
    end
  end
end
