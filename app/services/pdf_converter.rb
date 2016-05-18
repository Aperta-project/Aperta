class PDFConverter
  include DownloadablePaper

  def initialize(paper, downloader = nil)
    @paper = paper
    @downloader = downloader # a user
    @publishing_info_presenter =
      PublishingInformationPresenter.new @paper, @downloader
  end

  def convert
    PDFKit.new(pdf_html,
               footer_right: @publishing_info_presenter.downloader_name,
               footer_font_name: 'Times New Roman',
               footer_font_size: '10').to_pdf
  end

  def pdf_html
    render('pdf',
           layout: nil,
           locals: { should_proxy_previews: false,
                     paper: @paper,
                     paper_body: paper_body,
                     publishing_info_presenter: @publishing_info_presenter })
  end
end
