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
      cleaned_pdf = remove_object_streams(uploaded_pdf_data)
      CombinePDF.parse(cleaned_pdf, allow_optional_content: true)
    end

    def remove_object_streams(a_pdf)
      # Persist file to disk
      src_loc = Rails.root.join("tmp/#{object_id}.pdf")
      cleaned_loc = Rails.root.join("#{object_id}-qpdf.pdf")
      File.open(src_loc, 'wb') { |fp| fp.write a_pdf }

      unless pdf_may_have_object_stream?(src_loc)
        File.unlink(src_loc)
        return a_pdf
      end

      # QPDF
      call_qpdf(src_loc, cleaned_loc)

      # read PDF back into memory as was before the cleaning process began
      cleaned_pdf = IO.read(cleaned_loc, mode: 'rb')
      cleaned_pdf = cleaned_pdf.force_encoding(Encoding::ASCII_8BIT)

      # delete the tmp files from the server
      File.unlink(src_loc)
      File.unlink(cleaned_loc)

      cleaned_pdf
    end

    # QPDF is the commandline tool which removes object streams for PDFs.
    def call_qpdf(in_file_path, out_file_path)
      system "qpdf --object-streams=disable #{in_file_path} #{out_file_path}"
    end

    def pdf_may_have_object_stream?(pdf_file_path)
      # PDF may have object streams if the version of the PDF is 1.5+
      pdf_data = Origami::PDF.read(pdf_file_path)
      pdf_data_head = pdf_data.header

      "#{pdf_data_head.major_version}#{pdf_data_head.minor_version}".to_i >= 15
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
