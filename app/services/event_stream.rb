class EventStream
  def self.post_event(paper_id, card_json)
    Thread.new do
      Net::HTTP.post_form(
        URI.parse(update_url),
        card: card_json, stream: name(paper_id), token: token
      )
    end
  end

  def self.connection_info(paper_id)
    {
      url: url,
      eventName: name(paper_id)
    }
  end

  def self.name(paper_id)
    Digest::MD5.hexdigest "paper_#{paper_id}"
  end

  def self.token
    ENV["ES_TOKEN"] || 'token123' # Digest::MD5.hexdigest("some token")
  end

  def self.url
    ENV["ES_URL"] || "http://localhost:8080/stream?token=#{token}"
  end

  def self.update_url
    ENV["ES_UPDATE_URL"] || "http://localhost:8080/update_stream"
  end
end
