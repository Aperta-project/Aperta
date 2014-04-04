module TaskFactory
  class MessageTaskFactory
    def self.build(message_params, user)
      phase = Phase.find message_params[:phase_id]
      subject = message_params[:title]
      body = message_params[:body]
      participant_ids = message_params[:participant_ids] || user.id # participant_id cant be nil
      MessageTask.transaction do
        message_task = phase.message_tasks.create!(title: subject, participant_ids: participant_ids)
        if body
          comment = message_task.comments.create!(body: body, commenter_id: user.id)
        end
        message_task
      end
    end
  end
end
