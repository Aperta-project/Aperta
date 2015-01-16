class EpubConverter
  attr_reader :paper, :include_source, :downloader

  def initialize(paper, downloader, include_source = false)
    @paper = paper
    @downloader = downloader
    @include_source = include_source
  end

  def file_name
    @file_name ||= paper.short_title.squish.downcase.tr(" ", "_") + ".epub"
  end

  def epub_stream
    @epub_stream ||= builder.generate_epub_stream
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

  # Yeah these methods that start with _ should be private
  # Unfortunately the way the GEPUB library works uses
  # instance eval so we need them to be public until
  # such time as we are angry enough to build it another way.
  #
  def _embed_source(workdir)
    FileUtils.mkdir_p _source_dir(workdir)
    File.open(_path_to_source(workdir), 'wb') do |f|
      f.write manuscript_contents
    end
  end

  def _source_dir(workdir)
    "#{workdir}/original_sources"
  end

  def _path_to_source(workdir)
    "#{_source_dir(workdir)}/source.docx"
  end

  def _epub_cover_path
    epub_cover = paper.journal.epub_cover
    if Rails.application.config.carrierwave_storage == :fog && epub_cover.file
      TahiEpub::Tempfile.create RestClient.get(epub_cover.file.url), delete: false do |file|
        file.path
      end
    else
      epub_cover.file.path
    end
  end

  def _epub_css
    TahiEpub::Tempfile.create paper.journal.epub_css, delete: false do |file|
      file.path
    end
  end

  private

  def write_to_file(dir, content, filename)
    File.open(File.join(dir, filename), 'w+') do |file|
      file.write content
      file.flush
      file.path
    end
  end

  def builder
    Dir.mktmpdir do |dir|
      publishing_info_file_path = write_to_file dir,
                                                publishing_information_html,
                                                'publishing_information.html'

      content_file_path = write_to_file dir,
                                        epub_html,
                                        'content.html'

      generate_epub_builder publishing_info_file_path, content_file_path
    end
  end

  def generate_epub_builder(publishing_info_path, temp_paper_path)
    workdir = File.dirname temp_paper_path
    this = self

    epub = GEPUB::Builder.new do
      language 'en'
      unique_identifier 'http://tahi.org/hello-world', 'B, falseookID', 'URL'
      title this.paper.title || this.paper.short_title
      creator this.paper.creator.full_name
      date Date.today.to_s
      if this.include_source && this.paper.manuscript.present?
        this._embed_source(workdir)
        optional_file "original_sources/source.docx" => this._path_to_source(workdir)
      end
      resources(workdir: workdir) do
        file 'css/default.css' => this._epub_css
        cover_image 'images/cover_image.jpg' => this._epub_cover_path if this.paper.journal.epub_cover.file
        ordered do
          file "./#{File.basename publishing_info_path}"
          file "./#{File.basename temp_paper_path}"
          heading 'Main Content'
        end
      end
    end
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

  def manuscript_source
    paper.manuscript.source
  end

  def manuscript_contents
    manuscript_source.download!(manuscript_source.url)
    manuscript_source.file.read
  end
end
