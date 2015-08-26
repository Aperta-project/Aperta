class Comment::Created::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.task.paper)
  end

  def payload
    CommentSerializer.new(record).as_json
  end

end
