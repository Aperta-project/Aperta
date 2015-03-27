class EventStreamConnection
  attr_reader :user

  def as_json(options={})
    {
      enabled: self.class.enabled?,
      host: ENV["EVENT_STREAM_WS_HOST"],
      port: ENV["EVENT_STREAM_WS_PORT"],
      key: Pusher.key,
      channels: default_channels
    }
  end

  def default_channels
    ["system"]
  end

  def self.enabled?
    ENV["EVENT_STREAM_ENABLED"] != "false"
  end
end
