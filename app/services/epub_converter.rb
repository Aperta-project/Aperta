class EpubConverter
  def self.generate_epub(paper, include_source=false)
    converter = new(paper, include_source)

    builder = Dir.mktmpdir do |dir|
      File.open(File.join(dir, 'content.html'), 'w+') do |file|
        html = converter.construct_epub_html
        file.write html
        file.flush
        converter.generate_epub_builder(file.path)
      end
    end

    {
      stream: builder.generate_epub_stream,
      file_name: converter.construct_epub_name
    }
  end

  attr_reader :paper, :include_source

  def initialize(paper, include_source)
    @paper = paper
    @include_source = include_source
  end

  def generate_epub_builder(temp_paper_path)
    workdir = File.dirname temp_paper_path
    this = self # because instance_eval (JS devs see me trollin they hatin)

    GEPUB::Builder.new do
      language 'en'
      unique_identifier 'http://tahi.org/hello-world', 'BookID', 'URL'
      title this.paper.title || this.paper.short_title
      creator this.paper.user.full_name
      date Date.today.to_s
      resources(workdir: workdir) do
        # cover_image 'img/image1.jpg' => 'image1.jpg' #TODO: Figure out cover image
        ordered do
          file "./#{File.basename temp_paper_path}"
          heading 'Main Content'
          if this.include_source && this.paper.manuscript.present?
            file this.embed_source(workdir)
          end
        end
      end
    end
  end

  def construct_epub_name
    paper.short_title.squish.downcase.tr(" ", "_") + ".epub"
  end

  def embed_source(workdir)
    dest_dir = "#{workdir}/original_sources"
    src = paper.manuscript.source
    FileUtils.mkdir_p dest_dir
    File.open("#{dest_dir}/source.docx", 'wb') do |f|
      f.write src.file.read
    end
    src_path =  "./original_sources/#{File.basename src.path}"
  end

  def construct_epub_html
    body = paper.body || 'The manuscript is currently empty.'

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
    #{body.force_encoding('UTF-8')}
</body>
</html>
    HTMl
  end
end
