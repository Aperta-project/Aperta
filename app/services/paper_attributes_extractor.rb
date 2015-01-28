class PaperAttributesExtractor
  attr_reader :epub_stream

  def initialize(epub_url)
    @epub_stream = Faraday.get(epub_url).body
  end

  def to_hash
    {
      body: extract("body"),
      title: extract("title"),
      abstract: extract("abstract")
    }
  end

  def extract(filename)
    TahiEpub::Zip.extract(stream: epub_stream, filename: filename).force_encoding("UTF-8")
  rescue TahiEpub::FileNotFoundError => fnf
    nil # the filename doesn't exist in the response epub
  end
end
