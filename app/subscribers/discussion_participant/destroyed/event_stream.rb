class DiscussionParticipant::Destroyed::EventStream < EventStreamSubscriber

  def channel
    record.discussion_topic
  end

  def payload
    record.destroyed_payload
  end

end
