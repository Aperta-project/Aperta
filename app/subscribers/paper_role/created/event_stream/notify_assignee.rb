class PaperRole::Created::EventStream::NotifyAssignee < EventStreamSubscriber

  # this is necessary when the user is just now given access to the paper
  # and has yet to subscribe to the paper channel

  def channel
    private_channel_for(record.user)
  end

  def payload
    payload_for_record record.paper
  end

end
