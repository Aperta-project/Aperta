class PDFConverter
  include DownloadablePaper

  def initialize(paper, downloader = nil)
    @paper = paper
    @downloader = downloader # a user
    @publishing_info = PublishingInformationPresenter.new @paper, @downloader
  end

  def convert
    PDFKit.new(pdf_html,
               footer_right: @publishing_info.downloader_name,
               footer_font_name: 'Times New Roman',
               footer_font_size: '10').to_pdf
  end

  def pdf_html
    downloadable_templater
      .render(file: 'pdf/manuscript.erb',
              layout: 'pdf/layout',
              locals: {
                paper: @paper,
                paper_body: paper_body,
                orphan_figures: orphan_figures,
                publishing_info_presenter: @publishing_info,
                converter: self
              })
  end
end
