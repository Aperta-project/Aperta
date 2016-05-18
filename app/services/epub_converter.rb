# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'tahi_epub'

class EpubConverter
  attr_reader :paper, :include_source, :downloader, :include_cover_image

  include DownloadablePaper

  def initialize(paper,
                 downloader = nil,
                 include_source: false,
                 include_cover_image: true)
    @paper = paper
    @downloader = downloader # a user
    @include_source = include_source
    @include_cover_image = include_cover_image
  end

  def epub_stream
    @epub_stream ||= builder.generate_epub_stream
  end

  def title
    CGI.escape_html(paper.short_title.to_s)
  end

  def epub_html
    render('epub',
           layout: nil,
           locals: { paper: @paper,
                     paper_body: paper_body,
                     title: title,
                     should_proxy_previews: true
                   })
  end

  def publishing_information_html
    render('epub_publishing_information',
           layout: nil,
           locals: {
             paper: @paper,
             paper_body: paper_body,
             publishing_info_presenter:
               PublishingInformationPresenter.new(paper, downloader),
             title: title
           })
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
    "#{workdir}/input"
  end

  def _path_to_source(workdir)
    "#{_source_dir(workdir)}/#{_manuscript_source_path.basename}"
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

  def _manuscript_source_path
    Pathname.new(manuscript_source.file.path)
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

    GEPUB::Builder.new do
      language 'en'
      unique_identifier 'http://tahi.org/hello-world', 'B, falseookID', 'URL'
      title this.paper.display_title
      creator this.paper.creator.full_name
      date Date.today.to_s
      if this.include_source && this.paper.latest_version.present?
        this._embed_source(workdir)
        # keep same file extension as original file
        source_file_name = "source#{this._manuscript_source_path.extname}"
        optional_file "input/#{source_file_name}" => this._path_to_source(workdir)
      end
      resources(workdir: workdir) do
        file 'css/default.css' => this._epub_css
        if this.include_cover_image && this.paper.journal.epub_cover.file
          cover_image 'images/cover_image.jpg' => this._epub_cover_path
        end
        ordered do
          file "./#{File.basename publishing_info_path}"
          file "./#{File.basename temp_paper_path}"
          heading 'Main Content'
        end
      end
    end
  end

  def manuscript_source
    paper.latest_version.source
  end

  def manuscript_contents
    manuscript_source.download!(manuscript_source.url)
    manuscript_source.file.read
  end
end
