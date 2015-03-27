class EventStreamConnection
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def as_json(options={})
    {
      enabled: self.class.enabled?,
      host: ENV["EVENT_STREAM_HOST"],
      port: ENV["EVENT_STREAM_PORT"],
      key: Pusher.key,
      channels: default_channels
    }
  end

  def default_channels
    ["system", "private-user-#{user.id}"]
  end

  def self.enabled?
    ENV["EVENT_STREAM_ENABLED"] != "false"
  end
end
