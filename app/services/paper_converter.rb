class PaperConverter
  def self.export(paper, format, current_user)
    epub = EpubConverter.new(paper, current_user).epub_stream
    epub.rewind
    post_ihat_job(IhatJobRequest.new(file: epub, recipe_name: 'html_to_docx'))
  end

  def self.check_status(job_id)
    response = connection.get("/jobs/#{job_id}")
    IhatJobResponse.new(response.body.with_indifferent_access[:job])
  end

  def self.connection
    return @connection if @connection
    @connection = Faraday.new(url: ENV.fetch('IHAT_URL')) do |config|
      config.request :multipart
      config.response :json
      config.request :url_encoded
      config.adapter :net_http
    end
  end

  # Post a job to the ihat server.
  #
  # @return [IhatJobResponse]
  def self.post_ihat_job(req)
    # req.content_type could replace hardoced type below
    input = Faraday::UploadIO.new(req.file, 'application/epub+zip')
    response = connection.post('/jobs', job: {
                                 input: input,
                                 options: req.make_options
                               })
    IhatJobResponse.new(response.body.with_indifferent_access[:job])
  end
end
