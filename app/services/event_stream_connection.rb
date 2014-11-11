class EventStreamConnection

  SYSTEM_CHANNEL_NAME = "system"

  def self.post_user_event(id, json)
    _post_event(channel_name(User, id), json)
  end

  def self.post_system_event(json)
    _post_event(SYSTEM_CHANNEL_NAME, json)
  end

  def self.connection_info(user)
    {
      enabled: ENV["EVENT_STREAM_ENABLED"],
      url: channel_url,
      eventNames: [channel_name(user.class, user.id), SYSTEM_CHANNEL_NAME]
    }
  end

  def self.channel_name(klass, id)
    "#{klass.name.underscore.downcase}_#{id}"
  end

  def self.token
    ENV["ES_TOKEN"] || 'token123'
  end

  def self.url
    ENV["ES_URL"] || "http://localhost:8080"
  end

  def self.channel_url
    url + "/stream?token=#{token}"
  end

  def self.update_url
    url + "/update_stream"
  end

  def self.enabled?
    ENV["EVENT_STREAM_ENABLED"] != "false"
  end

  def self._post_event(channel, json)
    return unless enabled?
    Thread.new do
      Net::HTTP.post_form(
        URI.parse(update_url),
        stream: channel, card: json, token: token
      )
    end
  end
end
