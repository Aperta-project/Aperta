class EpubConverter
  def self.generate_epub paper
    builder = Dir.mktmpdir do |dir|
      File.open(File.join(dir, 'content.html'), 'w+') do |file|
        html = construct_epub_html paper
        file.write html
        file.flush
        generate_epub_builder paper, file.path
      end
    end

    {
      stream: builder.generate_epub_stream,
      file_name: construct_epub_name(paper)
    }
  end

  class << self
    private

    def construct_epub_name(paper)
      paper.short_title.squish.downcase.tr(" ", "_") + ".epub"
    end

    def generate_epub_builder(paper, temp_paper_path)
      workdir = File.dirname temp_paper_path
      GEPUB::Builder.new {
        language 'en'
        unique_identifier 'http://tahi.org/hello-world', 'BookID', 'URL'
        title paper.title || paper.short_title
        creator paper.user.full_name
        date Date.today.to_s
        resources(workdir: workdir) {
          # cover_image 'img/image1.jpg' => 'image1.jpg' #TODO: Figure out cover image
          ordered {
            file "./#{File.basename temp_paper_path}"
            heading 'Main Content'
          }
        }
      }
    end

    def construct_epub_html(paper)
      body = paper.body.force_encoding('UTF-8')

      # ePub is sensitive to leading white space, therefore we need the first
      # line to start at column 0. No, `String#strip_heredoc` doesn't solve the
      # problem.

      <<-HTMl
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>#{paper.short_title}</title>
</head>
<body>
  <h1>#{paper.title}</h1>
  #{body}
</body>
</html>
      HTMl
    end
  end
end
