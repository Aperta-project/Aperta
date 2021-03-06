# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

module PaperConverters
  class UnknownConversionError < StandardError; end

  # Base class of paper converters. Use ::make to get a particular instance of
  # a paper converter
  class PaperConverter
    def self.make(versioned_text, export_format, current_user)
      current_format = versioned_text.file_type
      klass = if [nil, current_format, 'source'].include?(export_format)
                direct_converter(export_format)
              elsif ['pdf', 'doc', 'docx'].include?(current_format)\
                  || ['pdf', 'pdf_with_attachments', 'pdf_for_router'].include?(export_format)
                dynamic_converter(current_format, export_format)
              end
      klass.new(versioned_text, export_format, current_user)
    end

    def self.direct_converter(export_format)
      if export_format == 'source'
        SourcePaperConverter
      else
        IdentityPaperConverter
      end
    end

    def self.dynamic_converter(current_format, export_format)
      if export_format == 'pdf_with_attachments' && current_format == 'pdf'
        PdfWithAttachmentsPaperConverter
      elsif (export_format == 'pdf' || export_format == 'pdf_with_attachments') && ['doc', 'docx'].include?(current_format)
        PdfPaperConverter
      elsif export_format == 'pdf_for_router' && ['doc', 'docx'].include?(current_format)
        AutoGeneratedDocxToPdfConverter
      elsif export_format == 'pdf_for_router' && ['pdf'].include?(current_format)
        AutoGeneratedPdfToPdfConverter
      else
        raise(
          UnknownConversionError,
          "Unknown conversion: #{current_format} to #{export_format}"
        )
      end
    end

    def initialize(versioned_text, export_format, current_user = nil)
      @versioned_text = versioned_text
      @export_format  = export_format
      @current_user = current_user
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
