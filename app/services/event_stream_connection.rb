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

  def authorized?(user:, channel_name:)
    channel = ChannelNameParser.new(channel_name: channel_name)
    return true if channel.public?
    return false unless Paper.exists?(channel.get(:paper))
    return false unless user.id.to_s == channel.get(:user)
    Accessibility.new(Paper.find(channel.get(:paper))).users.include?(user)
  end

  def authenticate(channel_name:, socket_id:)
    Pusher[channel_name].authenticate(socket_id)
  end

  def default_channels
    ["system", "private-user-#{user.id}"]
  end

  def self.enabled?
    ENV["EVENT_STREAM_ENABLED"] != "false"
  end

  # TODO: only send to users that have "presence"
  # TODO: exclude specific sockets
  def self.post_event(channel_name:, action:, payload:)
    Pusher.trigger(channel_name, action, payload)
  end

end
