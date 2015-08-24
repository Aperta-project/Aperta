class Comment::Updated::EventStream < EventStreamSubscriber

  def channel
    record.task.paper
  end

  def payload
    record.payload
  end

end
