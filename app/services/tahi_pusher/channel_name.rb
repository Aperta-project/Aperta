module TahiPusher
  class ChannelName
    CHANNEL_SEPARATOR = "-"
    MODEL_SEPARATOR   = "@"
    PRESENCE          = "presence"
    PRIVATE           = "private"
    PUBLIC            = "public"

    # <#Paper:1234 @id=4> --> "private-paper@4"
    def self.build(target:, access:)
      prefix = access unless access == PUBLIC
      suffix = if target.is_a?(ActiveRecord::Base)
                 [target.class.name.downcase, target.id].join(MODEL_SEPARATOR)
               else
                 target
               end
      [prefix, suffix].compact.join(CHANNEL_SEPARATOR)
    end

    # "private-paper@4" --> <#TahiPusher::ChannelName @prefix="private" @suffix="paper@4">
    def self.parse(channel_name)
      new(channel_name)
    end


    attr_reader :name, :prefix, :suffix

    def initialize(name)
      @name = name
      @prefix, _, @suffix = name.rpartition(CHANNEL_SEPARATOR)
    end

    def access
      prefix.presence || PUBLIC
    end

    def target
      model, _, id = suffix.partition(MODEL_SEPARATOR)
      if id.present?
        model.classify.constantize.find(id)
      else
        model
      end
    end
  end
end
