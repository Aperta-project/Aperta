class DiscussionParticipant::Created::NotifyExistingParticipants < EventStreamSubscriber

  def channel
    record.discussion_topic
  end

  def payload
    DiscussionParticipantSerializer.new(record).to_json
  end

end
