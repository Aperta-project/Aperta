class EpubConverter
  def self.generate_epub paper, user, &block
    temp_paper = Tempfile.new 'temp-paper.html'
    html = construct_epub_html paper
    temp_paper.write html
    temp_paper.flush

    epub_name = construct_epub_name paper
    builder = generate_epub_builder paper, temp_paper

    begin
      block.call builder.generate_epub_stream, epub_name
    ensure
      temp_paper.unlink
    end
  end


  private
  def self.construct_epub_name(paper)
    paper.short_title.squish.downcase.tr(" ", "_") + ".epub"
  end

  def self.generate_epub_builder(paper, temp_paper)
    GEPUB::Builder.new {
      language 'en'
      unique_identifier 'http://example.com/hello-world', 'BookID', 'URL'
      title paper.title || paper.short_title
      creator paper.user.full_name
      date Date.today.to_s

      resources(:workdir => '.') {
        # cover_image 'img/image1.jpg' => 'image1.jpg' #TODO: Figure out cover image
        ordered {
          file temp_paper.path
          heading 'Chapter 1'
        }
      }
    }
  end

  def self.construct_epub_html(paper)
    body = paper.body.force_encoding('UTF-8')

    <<-HTML
      <?xml version="1.0" encoding="UTF-8"?>
      <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>#{paper.short_title}</title>
      </head>
      <body>
        #{body}
      </body>
      </html>
    HTML
  end

end
