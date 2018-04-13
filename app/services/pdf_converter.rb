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

# PDF Converter -- Deprecated
class PDFConverter
  include DownloadablePaper

  def initialize(paper, downloader = nil)
    @paper = paper
    @downloader = downloader # a user
    @publishing_info_presenter =
      PublishingInformationPresenter.new @paper, @downloader
  end

  def convert
    PDFKit.new(pdf_html,
               footer_right: @publishing_info_presenter.downloader_name,
               footer_font_name: 'Times New Roman',
               footer_font_size: '10').to_pdf
  end

  def supporting_information_files
    @paper.supporting_information_files.map do |si_file|
      PaperConverters::SupportingInformationFileProxy
        .from_supporting_information_file(si_file)
    end
  end

  def pdf_html
    render(
      'pdf',
      layout: nil,
      locals: {
        should_proxy_previews: false,
        paper: @paper,
        paper_body: paper_body,
        publishing_info_presenter: @publishing_info_presenter,
        supporting_information_files: supporting_information_files
      }
    )
  end
end
