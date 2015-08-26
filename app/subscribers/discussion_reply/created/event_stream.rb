class DiscussionReply::Created::EventStream < EventStreamSubscriber

  def channel
    record.discussion_topic
  end

  def payload
    DiscussionReplySerializer.new(record).to_json
  end

end
