class PaperAttributesExtractor
  attr_reader :epub_stream

  def initialize(epub_stream)
    @epub_stream = epub_stream
  end

  def sync!(paper)
    paper.update!(
      body: extract_file('body'),
      abstract: extract_abstract,
      title: extract_file('title') || paper.title
    )
  end

  private

  def extract_abstract
    abstract = extract_file('abstract')
    return unless abstract
    return nil if word_count(abstract) > max_abstract_length

    abstract
  end

  def word_count(str)
    str.split.size
  end

  def max_abstract_length
    ENV.fetch('MAX_ABSTRACT_LENGTH', 1000).to_i
  end

  def extract_file(filename)
    TahiEpub::Zip.extract(stream: epub_stream, filename: filename).force_encoding("UTF-8")
  rescue TahiEpub::FileNotFoundError => e
    nil # the filename doesn't exist in the response epub
  end
end
