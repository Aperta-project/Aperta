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
      filename = @versioned_text.paper.display_title.gsub(/[^)(\d\w\s_-]+/, '')
      filename = filename[0..149] # limit to 150 chars
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

    # rubocop:disable Rails/OutputSafety
    def paper_body
      @versioned_text.figureful_text(direct_img_links: true).html_safe
    end

    def pdf_html
      render(
        'pdf',
        layout: nil,
        locals: {
          should_proxy_previews: false,
          paper: @versioned_text.paper,
          paper_body: paper_body,
          publishing_info_presenter: publishing_info_presenter,
          supporting_information_files: supporting_information_files
        }
      )
    end
  end
end
