class EpubConverter
  def self.convert(paper, downloader, include_source = false)
    converter = new(paper, downloader, include_source)

    {
      stream: converter.builder.generate_epub_stream,
      file_name: converter.epub_name
    }
  end

  attr_reader :paper, :include_source, :downloader

  def initialize(paper, downloader, include_source)
    @paper = paper
    @downloader = downloader
    @include_source = include_source
  end

  def builder
    Dir.mktmpdir do |dir|
      publishing_info_file_path = write_to_file(dir,
                                                publishing_information_html,
                                                'publishing_information.html')
      content_file_path = write_to_file(dir,
                                        epub_html,
                                        'content.html')

      generate_epub_builder publishing_info_file_path, content_file_path
    end
  end

  def generate_epub_builder(publishing_information_path, temp_paper_path)
    workdir = File.dirname temp_paper_path
    this = self

    GEPUB::Builder.new do
      language 'en'
      unique_identifier 'http://tahi.org/hello-world', 'BookID', 'URL'
      title this.paper.title || this.paper.short_title
      creator this.paper.user.full_name
      date Date.today.to_s
      resources(workdir: workdir) do
        file 'css/default.css' => this.epub_css
        cover_image 'images/cover_image.jpg' => this.epub_cover_path if this.paper.journal.epub_cover.file
        ordered do
          file "./#{File.basename publishing_information_path}"
          file "./#{File.basename temp_paper_path}"
          heading 'Main Content'
          if this.include_source && this.paper.manuscript.present?
            file this.path_to(this.embed_source(workdir))
          end
        end
      end
    end
  end

  def epub_name
    paper.short_title.squish.downcase.tr(" ", "_") + ".epub"
  end

  def embed_source(workdir)
    dest_dir = "#{workdir}/original_sources"
    src = paper.manuscript.source
    FileUtils.mkdir_p dest_dir
    File.open("#{dest_dir}/source.docx", 'wb') do |f|
      f.write src.file.read
    end
    src
  end

  def path_to(source)
    "./original_sources/#{File.basename source.path}"
  end

  def epub_html
    paper_body = paper.body || 'The manuscript is currently empty.'

    head = <<-HEAD
  <title>#{paper.short_title}</title>
  <link rel="stylesheet" type="text/css" href="css/default.css">
    HEAD

    body = <<-BODY
  <h1>#{paper.title}</h1>
  #{paper_body.force_encoding('UTF-8')}
    BODY

    layout_html head, body
  end

  def publishing_information_html
    publishing_info_presenter = PublishingInformationPresenter.new paper, downloader

    head = <<-HEAD
  <title>Publishing Information</title>
  <style>
    #{publishing_info_presenter.css}
  </style>
    HEAD

    layout_html head, publishing_info_presenter.html
  end

  def epub_cover_path
    epub_cover = paper.journal.epub_cover
    if Rails.application.config.carrierwave_storage == :fog && epub_cover.file
      image_temp = Tempfile.new("epub_cover")
      image_temp.binmode
      image_temp.write RestClient.get(epub_cover.file.url)
      image_temp.close
      image_temp.path
    else
      epub_cover.file.path
    end
  end

  def epub_css
    epub_css = paper.journal.epub_css
    css_temp = Tempfile.new("epub_css")
    css_temp.write epub_css
    css_temp.close
    css_temp.path
  end

  def layout_html(head, body)
    # ePub is sensitive to leading white space, therefore we need the first
    # line to start at column 0. No, `String#strip_heredoc` doesn't solve the
    # problem.

    <<-HTML
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  #{head}
</head>
<body>
  #{body}
</body>
    HTML
  end

  private

  def write_to_file(dir, content, filename)
    File.open(File.join(dir, filename), 'w+') do |file|
      file.write content
      file.flush
      file.path
    end
  end
end
