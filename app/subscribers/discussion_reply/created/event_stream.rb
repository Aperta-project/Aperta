class DiscussionReply::Created::EventStream < EventStreamSubscriber

  def channel
    record.discussion_topic
  end

  def payload
    record.payload
  end

end
