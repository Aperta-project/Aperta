module PaperConverters
  # Adds figures to the end of PDFs
  class PdfWithFiguresPaperConverter < PaperConverter
    include RenderAnywhere
    include DownloadablePaper

    def convert
      fetch_uploaded_pdf
      create_figures_pdf
      merge_updaded_and_figures_pdf
    end

    def create_figures_pdf
      create_figures_html
      create_pdf_from_figures_html
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
