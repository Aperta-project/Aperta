class PaperAttributesExtractor
  attr_reader :epub_stream

  def initialize(epub_stream)
    @epub_stream = epub_stream
  end

  def sync!(paper)
    paper.update!(
      body: extract_file('body'),
      abstract: extract_file('abstract'),
      title: extract_file('title') || paper.title
    )
  end

  private

  def extract_file(filename)
    TahiEpub::Zip.extract(stream: epub_stream, filename: filename).force_encoding("UTF-8")
  rescue TahiEpub::FileNotFoundError => e
    nil # the filename doesn't exist in the response epub
  end
end
