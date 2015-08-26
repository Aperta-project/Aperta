class DiscussionReply::Destroyed::EventStream < EventStreamSubscriber

  def channel
    record.discussion_topic
  end

  def payload
    destroyed_payload
  end

end
