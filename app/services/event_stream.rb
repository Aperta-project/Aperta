class EventStream

  def self.post_event(id, type, json)
    return unless enabled?
    Thread.new do
      Net::HTTP.post_form(
        URI.parse(update_url),
        card: json, stream: parse_stream(type, id), token: token
      )
    end
  end

  def self.connection_info(streams)
    {
      enabled: ENV["EVENT_STREAM_ENABLED"],
      url: stream_url,
      eventNames: parse_streams(streams)
    }
  end

  def self.parse_streams(models)
    models.map do |model|
      parse_stream(model.class, model.id)
    end
  end

  def self.parse_stream(type, id)
    "#{type.name.underscore.downcase}_#{id}"
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
