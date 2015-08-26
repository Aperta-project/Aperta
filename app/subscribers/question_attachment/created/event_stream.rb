class QuestionAttachment::Created::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.question.task.paper)
  end

  def payload
    QuestionAttachmentSerializer.new(record).to_json
  end

end
