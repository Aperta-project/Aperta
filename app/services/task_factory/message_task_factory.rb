module TaskFactory
  class MessageTaskFactory
    def self.build(message_params, user)
      phase = Phase.find message_params[:phase_id]
      title = message_params[:title]
      body = message_params[:body]
      MessageTask.transaction do
        message_task = MessageTask.create!(phase: phase, title: title)
        if body.present?
          comment = message_task.comments.create!(body: body, commenter_id: user.id)
        end
        message_task
      end
    end
  end
end
