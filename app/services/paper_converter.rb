class PaperConverter
  def self.export(paper, format, current_user)
    epub = EpubConverter.new(paper, current_user).epub_stream
    epub.rewind
    payload = Faraday::UploadIO.new(epub, "application/epub+zip")
    post_ihat_job(payload, format: format)
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

  def self.post_ihat_job(file, format: 'docx')
    connection.post("/jobs", job: {
      input: file,
      options: {
        recipe_name: "html_to_#{format}"
      }
    }).body
  end

end
