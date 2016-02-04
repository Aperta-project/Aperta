module PlosBioTechCheck
  module TechCheckController
    def send_email
      @task = Task.find(params[:id])

      if update_changes_for_author_task!(@task, letter_text(@task))
        @task.notify_changes_for_author
        add_user_participations current_user
        Activity.task_sent_to_author! @task, user: current_user
        render json: { success: true }
      end
    end

    def update_changes_for_author_task!(task, text)
      changes_for_author_task = task.changes_for_author_task

      changes_for_author_task.body["initialTechCheckBody"] = text
      changes_for_author_task.save!
    end

    def add_user_participations(user)
      users = [user] + @task.paper.collaborators
      users.each do |user|
        ParticipationFactory.create(
          assignee: user,
          task: @task.changes_for_author_task
        )
      end
    end
  end
end
