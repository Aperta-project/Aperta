class QuestionAttachment::Destroyed::EventStream < EventStreamSubscriber

  def channel
    record.question.task.paper
  end

  def payload
    destroyed_payload
  end

end
