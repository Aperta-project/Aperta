module PaperConverters
  # Adds figures to the end of PDFs
  class PdfWithAttachmentsPaperConverter < SynchronousPaperConverter
    include RenderAnywhere
    include DownloadablePaper

    def output_data
      user_pdf = parsed_uploaded_pdf
      attachments_pdf = create_attachments_pdf
      merge_pdfs([user_pdf, attachments_pdf]).to_pdf
    end

    def output_filename
      filename = @versioned_text.paper.display_title.gsub(/[^)(\d\w\s_-]+/, '')
      filename = filename[0..149] # limit to 150 chars
      "#{filename}_with_attachments.pdf"
    end

    def output_filetype
      'application/pdf'
    end

    def uploaded_pdf_data
      url = Attachment.authenticated_url_for_key(@versioned_text.s3_full_path)
      Net::HTTP.get_response(URI.parse(url)).body
    end

    def parsed_uploaded_pdf
      CombinePDF.parse uploaded_pdf_data
    end

    def merge_pdfs(pdfs)
      CombinePDF.new.tap do |pdf|
        pdfs.each { |fragment_pdf| pdf << fragment_pdf }
      end
    end

    def create_attachments_pdf
      html = create_attachments_html
      pdf_data = PDFKit.new(
        html,
        footer_font_name: 'Times New Roman',
        footer_font_size: '10' # TODO: I deleted a thing here
      ).to_pdf
      CombinePDF.parse(pdf_data)
    end

    # TODO: this shouldn't depend on paper -- needs to be able to version
    def create_attachments_html
      if @versioned_text == @versioned_text.paper.latest_version
        figures = @versioned_text.paper.figures
      else
        raise "I don't know how to do this yet"
      end

      render(
        'pdf_with_attachments',
        layout: nil,
        locals: {
          figures: figures,
          paper: @versioned_text.paper, # TODO: dont pass paper into here
          journal_pdf_css: @versioned_text.paper.journal.pdf_css
        }
      )
    end
  end
end
