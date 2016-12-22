# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'tahi_epub'

class PaperAttributesExtractor
  attr_reader :epub_stream

  def initialize(epub_stream)
    @epub_stream = epub_stream
  end

  def sync!(paper)
    if paper.file_type == 'pdf'
      # Since there is no grobid integration right now, we are just setting the
      # body to a known value to force an update
      paper.update!(
        body: "PDF Uploaded: " + DateTime.now.utc.to_s
      )
    else
      paper.update!(
        body: extract_file('body'),
        abstract: extract_abstract,
        title: extract_file('title') || paper.title
      )
    end
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
