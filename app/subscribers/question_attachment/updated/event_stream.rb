class QuestionAttachment::Updated::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.question.task.paper)
  end

  def payload
    QuestionAttachmentSerializer.new(record).as_json
  end

end
