class PaperRole::Destroyed::EventStream::NotifyEveryone < EventStreamSubscriber

  # this is necessary when the user is just now given access to the paper
  # and has yet to subscribe to the paper channel

  def channel
    private_channel_for(record.paper)
  end

  def payload
    payload_for_record record.paper
  end

  def action
    'updated'
  end

end
