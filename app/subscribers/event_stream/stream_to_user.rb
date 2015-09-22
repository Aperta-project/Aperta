class EventStream::StreamToUser < EventStreamSubscriber
  def channel
    private_channel_for(record.user)
  end
end
