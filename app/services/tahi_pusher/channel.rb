module TahiPusher
  class Channel
    attr_reader :channel_name

    def initialize(channel_name:)
      @channel_name = channel_name
    end

    def authorized?(user:)
      return true if public?
      return false unless Paper.exists?(extract_model_id(:paper))
      Accessibility.new(Paper.find(extract_model_id(:paper))).users.include?(user)
    end

    def authenticate(socket_id:)
      Pusher[channel_name].authenticate(socket_id)
    end

    def push(event_name:, payload:)
      Pusher.trigger(channel_name, event_name, payload)
    end

    def private?
      parsed_channel.has_key?(:private)
    end

    def public?
      !private?
    end


    private

    def parsed_channel
      @parsed_channel ||= ChannelName.parse(channel_name)
    end

    def extract_model_id(model_name)
      parsed_channel.fetch(model_name)
    end
  end
end
