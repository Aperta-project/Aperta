class DiscussionTopic::Created::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record)
  end

  def payload
    DiscussionTopicSerializer.new(record).to_json
  end

end
