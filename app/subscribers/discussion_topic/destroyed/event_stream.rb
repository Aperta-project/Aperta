class DiscussionTopic::Destroyed::EventStream < EventStreamSubscriber

  def channel
    record
  end

  def payload
    record.destroyed_payload
  end

end
