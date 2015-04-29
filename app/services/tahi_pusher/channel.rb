module TahiPusher
  class Channel
    attr_reader :channel_name

    def initialize(channel_name:)
      @channel_name = channel_name
    end

    def authorized?(user:)
      channel = ChannelNameParser.new(channel_name: channel_name)
      return true if channel.public?
      return false unless Paper.exists?(channel.get(:paper))
      Accessibility.new(Paper.find(channel.get(:paper))).users.include?(user)
    end

    def authenticate(socket_id:)
      Pusher[channel_name].authenticate(socket_id)
    end
  end
end
