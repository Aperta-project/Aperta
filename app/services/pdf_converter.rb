class PDFConverter

  def self.convert(paper, downloader)
    publishing_info = PublishingInformationPresenter.new paper, downloader
    paper_body = PaperDownloader.new(paper).body

    PDFKit.new(pdf_html(paper, publishing_info, paper_body),
               footer_right: publishing_info.downloader_name,
               footer_font_name: 'Times New Roman',
               footer_font_size: '10').to_pdf
  end

  def self.pdf_html(paper, publishing_info_presenter, paper_body)
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
            <h1>#{CGI.escape_html(paper.display_title(sanitized: false))}</h1>
            #{paper_body}
          </div>
        </body>
      </html>
    HTML
  end
end
