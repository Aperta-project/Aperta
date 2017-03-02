module PaperConverters
  class UnknownConversionError < StandardError; end

  # Base class of paper converters. Use ::make to get a particular instance of
  # a paper converter
  class PaperConverter
    def self.make(versioned_text, export_format)
      current_format = versioned_text.file_type
      klass = if export_format == current_format || export_format.nil?
                IdentityPaperConverter
              elsif export_format == 'source'
                SourcePaperConverter
              elsif export_format == 'pdf_with_attachments'\
                && current_format == 'pdf'
                PdfWithAttachmentsPaperConverter
              else
                raise(
                  UnknownConversionError,
                  "Unknown conversion: #{current_format} to #{export_format}"
                )
              end
      klass.new(versioned_text, export_format)
    end

    def initialize(versioned_text, export_format)
      @versioned_text = versioned_text
      @export_format  = export_format
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
end
