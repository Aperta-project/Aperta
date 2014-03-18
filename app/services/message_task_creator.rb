class MessageTaskCreator

  def self.with_initial_comment(phase, message_params, creator)
    binding.pry
    subject = message_params[:message_subject]
    body = message_params[:message_body]
    participant_ids = message_params[:participant_ids]
    StandardTasks::MessageTask.transaction do
      message_task = phase.message_tasks.create!(title: subject, message_subject: subject, participant_ids: participant_ids)
      if body
        comment = message_task.comments.create!(body: body, commenter_id: creator.id)
      end
      message_task
    end
  end
end
