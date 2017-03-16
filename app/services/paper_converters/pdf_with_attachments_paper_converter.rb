module PaperConverters
  # Adds figures to the end of PDFs
  class PdfWithAttachmentsPaperConverter < SynchronousPaperConverter
    include UrlBuilder
    include DownloadablePaper

    def output_data
      user_pdf = parsed_uploaded_pdf
      attachments_pdf = create_attachments_pdf
      merge_pdfs([user_pdf, attachments_pdf]).to_pdf
    end

    def output_filename
      paper = @versioned_text.paper
      filename = "#{paper.short_doi} - #{paper.creator.last_name} "\
       "- #{@versioned_text.version}"
      "#{filename} (with attachments).pdf"
    end

    def output_filetype
      'application/pdf'
    end

    def uploaded_pdf_data
      url = Attachment.authenticated_url_for_key(@versioned_text.s3_full_path)
      Faraday.get(URI.parse(url)).body
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
        javascript_delay: 0
      ).to_pdf
      CombinePDF.parse(pdf_data)
    end

    def figures
      FigureProxy.from_versioned_text(@versioned_text).sort_by(&:rank)
    end

    def supporting_information_files
      SupportingInformationFileProxy.from_versioned_text(@versioned_text)
    end

    def create_attachments_html
      render(
        'pdf_with_attachments',
        layout: nil,
        locals: {
          figures: figures,
          supporting_information_files: supporting_information_files,
          journal_pdf_css: @versioned_text.paper.journal.pdf_css
        }
      )
    end
  end
end
