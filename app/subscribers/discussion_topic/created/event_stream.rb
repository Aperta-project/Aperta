class DiscussionTopic::Created::EventStream < EventStreamSubscriber

  def channel
    record
  end

  def payload
    record.payload
  end

end
