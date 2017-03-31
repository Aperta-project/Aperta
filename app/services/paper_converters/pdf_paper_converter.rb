module PaperConverters
  # PDF Converter used to convert docx papers
  class PdfPaperConverter < SynchronousPaperConverter
    include DownloadablePaper

    def output_data
      PDFKit.new(pdf_html,
        footer_right: publishing_info_presenter.downloader_name,
        footer_font_name: 'Times New Roman',
        footer_font_size: '10').to_pdf
    end

    def output_filename
      paper = @versioned_text.paper
      filename = "#{paper.short_doi} - #{paper.creator.last_name} "\
       "- #{@versioned_text.version}"
      "#{filename}.pdf"
    end

    def output_filetype
      'application/pdf'
    end

    def supporting_information_files
      SupportingInformationFileProxy.from_versioned_text(@versioned_text)
    end

    def publishing_info_presenter
      PublishingInformationPresenter.new(@versioned_text.paper, @current_user)
    end

    def pdf_html
      render(
        'pdf',
        layout: nil,
        locals: {
          should_proxy_previews: false,
          paper: @versioned_text.paper,
          paper_body: @versioned_text.materialized_content,
          publishing_info_presenter: publishing_info_presenter,
          supporting_information_files: supporting_information_files
        }
      )
    end
  end
end
