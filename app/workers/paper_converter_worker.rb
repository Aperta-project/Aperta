class PaperConverterWorker
  def self.export(paper, format, current_user)
    epub = EpubConverter.new(paper, current_user).epub_stream
    epub.rewind

    connection = Faraday.new(url: ENV.fetch('IHAT_URL')) do |c|
      c.request :multipart
      c.request :url_encoded
      c.use Faraday::Adapter::NetHttp
    end

    payload = Faraday::UploadIO.new(epub, "application/epub+zip")
    payload_body = { export_format: format, epub: payload }
    response = connection.post('/jobs', payload_body)

    JSON.parse(response.body)['jobs']['id']
  end
end
