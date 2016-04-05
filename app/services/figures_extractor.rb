class FiguresExtractor
  attr_reader :epub_stream

  def initialize(epub_stream)
    @epub_stream = epub_stream
  end

  def sync!(paper)
    paper.transaction do
      f = Nokogiri::XML.fragment(paper.body)
      f.search('.//img').remove
      relinked_html = f
      paper.update!(body: relinked_html)
    end
  end

  private

  # replace each <a href> to point to the newly created figure url
  # in the near future we will move to a system where authors simply use a
  # "placeholder" # for figures, and upload them manually via the figures card.
  # This step with then become a place to "strip" paper body of actual figures,
  # or maybe replace them with placeholders
  def relinked_image_anchor(html:, image:, figure:)
    Nokogiri::HTML(html).tap { |doc|
      doc.css("img[src*='#{image.original_filename}']").each do |img|
        # hardcodes these attributes in db paper.body
        img.set_attribute 'src', figure.non_expiring_proxy_url(version: :detail)
        img.set_attribute 'id', "figure_#{figure.id}"
        img.set_attribute 'data-figure-id', figure.id
        img.set_attribute 'alt', "Figure: #{figure.filename}"
        img.set_attribute 'class', 'paper-body-figure'

        img.attributes['style'].remove # removes width set in tahi
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
