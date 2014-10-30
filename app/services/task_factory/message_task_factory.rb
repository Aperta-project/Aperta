module TaskFactory
  class MessageTaskFactory
    def self.build(message_params, user)
      MessageTask.transaction do
        MessageTask.create!(message_params.slice(:phase_id, :title, :role)).tap do |message_task|
          body = message_params[:body]
          if body.present?
            message_task.comments.create!(body: body, commenter_id: user.id)
          end
        end
      end
    end
  end
end
