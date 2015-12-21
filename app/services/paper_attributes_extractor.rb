# Updates paper with attributes extracted from an epub returned from ihat
class PaperAttributesExtractor
  attr_reader :epub_stream

  def initialize(epub_stream)
    @epub_stream = epub_stream
  end

  def sync!(paper)
    paper.update!(attributes(paper))
  end

  def attributes(paper)
    @attributes ||= {
      body: extract_body(paper),
      title: extract_title(paper),
      abstract: extract_file('abstract')
    }
  end

  private

  def extract_body(paper)
    title = extract_title(paper)
    body = extract_file('body')

    body.sub(title, "<h3 data-aperta-title='#{title}'></h3>") if title
  end

  def extract_title(paper)
    paper.title unless paper.title.blank?
    extract_file('title')
  end

  def extract_file(filename)
    TahiEpub::Zip.extract(stream: epub_stream, filename: filename) \
      .force_encoding('UTF-8')
  rescue TahiEpub::FileNotFoundError
    nil # the filename doesn't exist in the response epub
  end
end
