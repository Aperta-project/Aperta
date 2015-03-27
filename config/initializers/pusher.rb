if EventStreamConnection.enabled?
  Pusher.host   = ENV.fetch("EVENT_STREAM_HOST")
  Pusher.port   = ENV.fetch("EVENT_STREAM_API_PORT")
  Pusher.app_id = ENV.fetch("EVENT_STREAM_APP_ID")
  Pusher.key    = ENV.fetch("EVENT_STREAM_KEY")
  Pusher.secret = ENV.fetch("EVENT_STREAM_SECRET")
end
