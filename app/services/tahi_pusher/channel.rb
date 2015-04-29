module TahiPusher
  class Channel
    CHANNEL_SEPARATOR = "-"
    MODEL_SEPARATOR   = "_"

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

    def private?
      parsed_channel.has_key?(:private)
    end

    def public?
      !private?
    end

    private

    def extract_model_id(model_name)
      parsed_channel.fetch(model_name)
    end

    # "private-paper_4" --> {private: true, paper: 4}
    def parsed_channel
      @parsed_channel ||= channel_name.split(CHANNEL_SEPARATOR).each_with_object({}) do |token, channel|
        model, id = token.split(MODEL_SEPARATOR)
        channel[model.to_sym] = id || true
      end
    end
  end
end
