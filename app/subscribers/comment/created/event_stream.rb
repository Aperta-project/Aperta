class Comment::Created::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.task.paper)
  end

  def payload
    CommentSerializer.new(record).to_json
  end

end
