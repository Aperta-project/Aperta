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

class PublishingInformationPresenter
  attr_reader :paper, :downloader

  def initialize(paper, downloader = nil)
    @paper = paper
    @downloader = downloader
  end

  def css
    <<-CSS
      #publishing-information {
        text-align: center;
        height: 100%;
        display: relative;
      }
    CSS
  end

  def html
    <<-HTML
      #{title}
      #{journal_name}
      #{generated_at}
    HTML
  end

  def title
    "<h1 id='paper-display-title'>#{paper.display_title(sanitized: false)}</h1>"
  end

  def journal_name
    "<p id='journal-name'><em>#{CGI.escape_html(paper.journal.name)}</em></p>"
  end

  def generated_at(date=nil)
    date ||= Date.today.to_s(:long)
    "<p id='generated-at'><em>#{CGI.escape_html(date)}</em></p>"
  end

  def downloader_name
    return '' unless downloader.present?
    "Generated for #{CGI.escape_html(downloader.full_name)}"
  end
end
