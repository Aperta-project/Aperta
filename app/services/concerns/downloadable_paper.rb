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

require 'render_anywhere'

class DownloadablePaperController < RenderAnywhere::RenderingController; end

# included in classes that create downloadable papers in various formats
module DownloadablePaper
  include RenderAnywhere

  def paper_body
    return 'The manuscript is currently empty.' if @paper.figureful_text.blank?
    body_with_aws_figure_urls.html_safe
  end

  # filename appropriate for a filesystem
  # handles size and bad chars
  def fs_filename
    filename = @paper.display_title.gsub(/[^)(\d\w\s_-]+/, '')
    filename = filename[0..149] # limit to 150 chars
    "#{filename}.#{document_type}"
  end

  def document_type
    # :pdf, :epub
    self.class.to_s.underscore.split('_').first.to_sym
  end

  def rendering_controller
    @rendering_controller ||= DownloadablePaperController.new
  end

  private

  def body_with_aws_figure_urls
    @paper.figureful_text(direct_img_links: true)
  end
end
