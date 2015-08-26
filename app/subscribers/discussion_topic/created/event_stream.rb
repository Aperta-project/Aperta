class DiscussionTopic::Created::EventStream < EventStreamSubscriber

  def channel
    record
  end

  def payload
    DiscussionTopicSerializer.new(record).to_json
  end

end
