class PaperConverter
  def self.export(paper, format, current_user)
    epub = EpubConverter.new(paper, current_user).epub_stream
    epub.rewind
    payload = Faraday::UploadIO.new(epub, "application/epub+zip")
    post_ihat_job(payload: payload,
                  options: {
                    recipe_name: 'html_to_docx'
                  })
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

  # Post a job to the ihat server.
  #
  # @return [IhatJobResponse]
  def self.post_ihat_job(payload:, options: {})
    response = connection.post('/jobs', job: {
                                 input: payload,
                                 options: options
                               })
    IhatJobResponse.new(JSON.parse(response.body).with_indifferent_access[:job])
  end
end
