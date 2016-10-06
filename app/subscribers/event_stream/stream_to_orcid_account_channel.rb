class EventStream::StreamToOrcidAccountChannel < EventStreamSubscriber
  def channel
    private_channel_for(record.user)
  end

  def run
    TahiPusher::Channel
      .delay(queue: :eventstream, retry: false)
      .push(
        channel_name: channel,
        event_name: action,
        payload: payload
      )
  end
end
