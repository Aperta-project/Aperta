class DiscussionReply::Updated::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.discussion_topic)
  end

  def payload
    DiscussionReplySerializer.new(record).as_json
  end

end
