module PaperConverters
  # Adds figures to the end of PDFs
  class PdfWithFiguresPaperConverter < PaperConverter
    include RenderAnywhere
    include DownloadablePaper

    def converted_data
      user_pdf = fetch_uploaded_pdf
      figures_pdf = create_figures_pdf
      merge_pdfs([user_pdf, figures_pdf]).to_pdf
    end

    def fetch_uploaded_pdf
      url = Attachment.authenticated_url_for_key(@versioned_text.s3_full_path)
      CombinePDF.parse Net::HTTP.get_response(URI.parse(url)).body
    end

    def merge_pdfs(pdfs)
      CombinePDF.new.tap do |pdf|
        pdfs.each { |fragment_pdf| pdf << fragment_pdf }
      end
    end

    def create_figures_pdf
      html = create_figures_html
      pdf_data = PDFKit.new(
        html,
        footer_font_name: 'Times New Roman',
        footer_font_size: '10'
      ).to_pdf
      CombinePDF.parse(pdf_data)
    end

    def create_figures_html
      if @versioned_text == @versioned_text.paper.latest_version
        figures = @versioned_text.paper.figures
      else
        raise "I don't know how to do this yet"
      end

      render(
        'pdf_with_figures',
        layout: nil,
        locals: {
          figures: figures
        }
      )
    end
  end
end
