class QuestionAttachment::Updated::EventStream < EventStreamSubscriber

  def channel
    record.question.task.paper
  end

  def payload
    record.payload
  end

end
