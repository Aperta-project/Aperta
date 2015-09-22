class DiscussionParticipant::Created::EventStream::NotifyAssignee < EventStreamSubscriber

  def channel
    private_channel_for(record.user)
  end

  def payload
    payload_for_record record.discussion_topic
  end
end
