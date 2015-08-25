class DiscussionParticipant::Created::NotifyAssignee < EventStreamSubscriber

  def channel
    record.user
  end

  def payload
    record.payload
  end

  def action
    'discussion-participant-created'
  end

end
