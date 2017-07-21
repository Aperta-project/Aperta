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
      paper = @paper_version.paper
      filename = "#{paper.short_doi} - #{paper.creator.last_name} "\
       "- #{@paper_version.version}"
      "#{filename}.pdf"
    end

    def output_filetype
      'application/pdf'
    end

    def supporting_information_files
      SupportingInformationFileProxy.from_paper_version(@paper_version)
    end

    def publishing_info_presenter
      PublishingInformationPresenter.new(@paper_version.paper, @current_user)
    end

    def pdf_html
      render(
        'pdf',
        layout: nil,
        locals: {
          should_proxy_previews: false,
          paper: @paper_version.paper,
          paper_body: @paper_version.materialized_content,
          publishing_info_presenter: publishing_info_presenter,
          supporting_information_files: supporting_information_files
        }
      )
    end
  end
end
