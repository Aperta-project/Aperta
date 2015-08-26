class Comment::Created::EventStream < EventStreamSubscriber

  def channel
    record.task.paper
  end

  def payload
    CommentSerializer.new(record).to_json
  end

end
