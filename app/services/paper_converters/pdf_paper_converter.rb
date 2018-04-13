# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

module PaperConverters
  # PDF Converter used to convert docx papers
  class PdfPaperConverter < SynchronousPaperConverter
    include DownloadablePaper

    def output_data
      PDFKit.new(pdf_html,
        footer_right: publishing_info_presenter.downloader_name,
        footer_font_name: 'Times New Roman',
        margin_right: 30, # in mm
        margin_left: 30,
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
