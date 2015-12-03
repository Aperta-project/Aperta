class FiguresExtractor
  attr_reader :epub_stream

  def initialize(epub_stream)
    @epub_stream = epub_stream
  end

  def sync!(paper)
    paper.transaction do
      relinked_html = paper.body
      images.each do |image|
        figure = paper.figures.create!(attachment: image, title: image.original_filename, status: 'done')
        relinked_html = relinked_image_anchor(html: relinked_html, image: image, figure: figure)
      end
      paper.update!(body: relinked_html)
    end
  end

  private

  # replace each <a href> to point to the newly created figure url
  def relinked_image_anchor(html:, image:, figure:)
    Nokogiri::HTML(html).tap { |doc|
      doc.css("img[src*='#{image.original_filename}']").each do |img|
        img.set_attribute('src', figure.attachment.preview.url)
      end
    }.to_s
  end


  def images
    return @images if @images

    directory = ::Zip::CentralDirectory.read_from_stream StringIO.new(epub_stream)
    @images = directory.select { |e| e.name =~ /images\// }.map do |entry|
      image_stream = entry.get_input_stream
      FileStringIO.new(image_stream.rewind.name, image_stream.read)
    end
  end
end
