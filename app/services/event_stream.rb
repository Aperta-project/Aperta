class EventStream

  def self.post_event(id, json)
    return unless enabled?

    Thread.new do
      Net::HTTP.post_form(
        URI.parse(update_url),
        card: json, stream: name(id), token: token
      )
    end
  end

  def self.connection_info(ids)
    {
      enabled: ENV["EVENT_STREAM_ENABLED"],
      url: stream_url,
      eventNames: names(ids)
    }
  end

  def self.names(ids)
    ids.map {|id| name(id) }
  end

  def self.name(id)
    "paper_#{id}"
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
