class QuestionAttachment::Created::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.question.owner.paper)
  end

  def payload
    QuestionAttachmentSerializer.new(record).as_json
  end

end
