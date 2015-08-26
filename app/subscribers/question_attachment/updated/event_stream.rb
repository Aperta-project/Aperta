class QuestionAttachment::Updated::EventStream < EventStreamSubscriber

  def channel
    record.question.task.paper
  end

  def payload
    QuestionAttachmentSerializer.new(record).to_json
  end

end
