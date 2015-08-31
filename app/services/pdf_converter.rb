class PDFConverter
  def self.convert(paper, downloader)
    publishing_info_presenter = PublishingInformationPresenter.new paper, downloader

    PDFKit.new(pdf_html(paper, publishing_info_presenter),
               footer_right: publishing_info_presenter.downloader_name,
               footer_font_name: 'Times New Roman',
               footer_font_size: '10').to_pdf
  end

  def self.pdf_html(paper, publishing_info_presenter)
    <<-HTML
      <html>
        <head>
          <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
          <style>
            #{publishing_info_presenter.css}
            #{paper.journal.pdf_css}
          </style>
        </head>
        <body>
          <div id='publishing-information'>
            #{publishing_info_presenter.html}
          </div>
          <div id='paper-body' styles='page-break-before: always;'>
            <h1>#{CGI.escape_html(paper.display_title)}</h1>
            #{paper.body}
          </div>
        </body>
      </html>
    HTML
  end
end
