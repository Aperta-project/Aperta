module TahiPusher
  class ChannelName
    CHANNEL_SEPARATOR = "-"
    MODEL_SEPARATOR   = "_"

    # <#Paper:1234 id:4> --> "private-paper_4"
    def self.build(model, scope: "private")
      suffix = [model.class.name.downcase, model.id].join(MODEL_SEPARATOR)
      [scope, suffix].join(CHANNEL_SEPARATOR)
    end

    # "private-paper_4" --> {private: true, paper: 4}
    def self.parse(channel_name)
      channel_name.split(CHANNEL_SEPARATOR).each_with_object({}) do |token, channel|
        model, id = token.split(MODEL_SEPARATOR)
        channel[model.to_sym] = id || true
      end
    end
  end
end
