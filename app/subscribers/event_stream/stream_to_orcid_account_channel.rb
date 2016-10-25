class EventStream::StreamToOrcidAccountChannel < EventStreamSubscriber
  def channel
    private_channel_for(record.user)
  end

  def run
    # Here we're piggybacking off the users channel, but we're not excluding the
    # socket that initiated the action (as is default with the stock user
    # channel).  We don't want to exclude ourselves because the popup window
    # initiates the update action, and we want the main parent window to be
    # notified via websocket.
    TahiPusher::Channel
      .delay(queue: :eventstream, retry: false)
      .push(
        channel_name: channel,
        event_name: action,
        payload: payload
      )
  end
end
