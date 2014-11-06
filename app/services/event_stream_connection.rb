class EventStreamConnection

  def self.post_event(klass, id, json)
    return unless enabled?
    Thread.new do
      Net::HTTP.post_form(
        URI.parse(update_url),
        stream: stream_name(klass, id), card: json, token: token
      )
    end
  end

  def self.connection_info(models)
    {
      enabled: ENV["EVENT_STREAM_ENABLED"],
      url: stream_url,
      eventNames: stream_names(*models)
    }
  end

  def self.stream_names(*models)
    models.map do |model|
      stream_name(model.class, model.id)
    end
  end

  def self.stream_name(klass, id)
    "#{klass.name.underscore.downcase}_#{id}"
  end

  def self.token
    ENV["ES_TOKEN"] || 'token123'
  end

  def self.url
    ENV["ES_URL"] || "http://localhost:8080"
  end

  def self.stream_url
    url + "/stream?token=#{token}"
  end

  def self.update_url
    url + "/update_stream"
  end

  def self.enabled?
    ENV["EVENT_STREAM_ENABLED"] != "false"
  end
end
