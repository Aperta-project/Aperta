class FiguresExtractor
  attr_reader :epub_stream, :images

  def initialize(epub_stream)
    @epub_stream = epub_stream
  end

  def sync!(paper)
    paper.transaction do
      images.map do |image|
        paper.figures.create!(attachment: image, title: image.original_filename, status: "done")
      end
    end
  end

  private

  def images
    return @images if @images

    directory = ::Zip::CentralDirectory.read_from_stream StringIO.new(epub_stream)
    @images = directory.select { |e| e.name =~ /images\// }.map do |entry|
      image_stream = entry.get_input_stream
      FileStringIO.new(image_stream.rewind.name, image_stream.read)
    end
  end
end
