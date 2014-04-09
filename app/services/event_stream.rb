class EventStream
  def self.post_event(paper_id, card_json)
    Thread.new do
      Net::HTTP.post_form(
        URI.parse(update_url),
        card: card_json, stream: name(paper_id), token: token
      )
    end
  end

  def self.connection_info(paper_ids)
    {
      url: stream_url,
      eventNames: names(paper_ids)
    }
  end

  def self.names ids
    ids.map {|id| name id }
  end

  def self.name(paper_id)
    Digest::MD5.hexdigest "paper_#{paper_id}"
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
end
