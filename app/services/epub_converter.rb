class EpubConverter
  def self.generate_epub paper, user, &block
    temp_paper = Tempfile.new 'temp-paper.html'
    html = construct_epub_html paper
    temp_paper.write html

    epub_path = construct_epub_path paper

    builder = generate_epub_builder paper, temp_paper
    builder.generate_epub epub_path

    begin
      block.call epub_path
    ensure
      temp_paper.unlink
    end
  end


  private
  def self.construct_epub_path(paper)
    epub_file_name = paper.short_title.squish.downcase.tr(" ", "_") + ".epub"
    File.join(Rails.root.join(epub_file_name))
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
    #TODO: get the paper title in there
    html_top = <<-EOD
      <?xml version="1.0" encoding="UTF-8"?>
      <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
      <title>#{paper.short_title}</title>
      </head>
      <body>
    EOD

    html_bottom = <<-EOD
      </body>
      </html>
    EOD

    html_top + paper.body.force_encoding('UTF-8') + html_bottom
  end

end
