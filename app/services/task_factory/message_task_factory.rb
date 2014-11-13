module TaskFactory
  class MessageTaskFactory
    def self.build(klass, message_params, user)
      klass.transaction do
        klass.create!(message_params.slice(:phase_id, :title, :role)).tap do |message_task|
          body = message_params[:body]
          if body.present?
            message_task.comments.create!(body: body, commenter_id: user.id)
          end
        end
      end
    end
  end
end
