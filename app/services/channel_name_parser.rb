class ChannelNameParser
  attr_reader :channel_name, :channel

  CHANNEL_SEPARATOR = "-"
  MODEL_SEPARATOR   = "_"

  def initialize(channel_name:)
    @channel_name = channel_name
  end

  def channel
    @channel ||= channel_name.split(CHANNEL_SEPARATOR).each_with_object({}) do |token, channel|
      model, id = token.split(MODEL_SEPARATOR)
      channel[model.to_sym] = id || true
    end
  end

  def get(key)
    channel.fetch(key)
  end

  def private?
    channel.has_key?(:private)
  end

  def public?
    !private?
  end
end
