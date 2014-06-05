class PDFConverter
  def self.convert(paper)
    PDFKit.new(pdf_html(paper)).to_pdf
  end

  def self.pdf_html(paper)
    <<-HTML
      <html>
        <head>
          <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
          <style>
            #{paper.journal.pdf_css}
          </style>
        </head>
        <body>
          <h1>#{paper.display_title}</h1>
          #{paper.body}
        </body>
      </html>
    HTML
  end
end
