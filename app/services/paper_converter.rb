class PaperConverter
  def self.export(paper, format, current_user)
    epub = EpubConverter.new(paper, current_user).epub_stream
    payload = Faraday::UploadIO.new(epub, "application/epub+zip")
    payload_body = { export_format: format, epub: payload }
    response = connection.post('/jobs', payload_body)
    response.body
  end

  def self.check_status(job_id)
    response = connection.get("/jobs/#{job_id}")
    response.body
  end

  def self.connection
    return @connection if @connection
    @connection = Faraday.new(url: ENV.fetch('IHAT_URL')) do |config|
      config.request :multipart
      config.request :url_encoded
      config.adapter :net_http
    end
  end
end
