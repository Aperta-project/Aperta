class PaperRole::Destroyed::EventStream::NotifyAssignee < EventStreamSubscriber

  def channel
    private_channel_for(record.user)
  end

  def payload
    destroyed_payload(record.paper)
  end

end
