class EventStream::StreamToDiscussionChannel < EventStreamSubscriber
  def channel
    if record.is_a? DiscussionTopic
      private_channel_for(record)
    else
      private_channel_for(record.discussion_topic)
    end
  end
end
