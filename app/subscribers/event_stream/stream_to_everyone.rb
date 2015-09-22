class EventStream::StreamToEveryone < EventStreamSubscriber
  def channel
    system_channel
  end
end
