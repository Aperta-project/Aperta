class DiscussionParticipant::Created::EventStream::NotifyExistingParticipants < EventStreamSubscriber

  def channel
    private_channel_for(record.discussion_topic)
  end

  def payload
    DiscussionParticipantSerializer.new(record).as_json
  end

end
