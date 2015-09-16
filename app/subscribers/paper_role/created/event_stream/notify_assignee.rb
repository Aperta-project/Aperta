class PaperRole::Created::EventStream::NotifyAssignee < EventStreamSubscriber

  # this is necessary when the user is just now given access to the paper
  # and has yet to subscribe to the paper channel

  def channel
    private_channel_for(record.user)
  end

  def payload
    assignee = record.user
    PaperSerializer.new(record.paper, user: assignee).as_json
  end

end
