class PaperConverter
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
    input = Faraday::UploadIO.new(req.file, req.content_type)
    response = connection.post('/jobs', job: {
                                 input: input,
                                 options: req.make_options
                               })
    IhatJobResponse.new(response.body.with_indifferent_access[:job])
  end
end
