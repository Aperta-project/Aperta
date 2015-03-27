if EventStreamConnection.enabled?
  Pusher.app_id = ENV.fetch("EVENT_STREAM_APP_ID")
  Pusher.key    = ENV.fetch("EVENT_STREAM_KEY")
  Pusher.secret = ENV.fetch("EVENT_STREAM_SECRET")
end
