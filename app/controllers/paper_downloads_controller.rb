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

# Controller for downloading papers
#
# In the future this can be expanded to handle async processing jobs, but for
# now, everything is returned synchronously.
class PaperDownloadsController < ApplicationController
  before_action :authenticate_user!

  def show
    requires_user_can(:view, paper)
    case converter
    when PaperConverters::RedirectingPaperConverter
      redirect_to(converter.download_url)
    when PaperConverters::SynchronousPaperConverter
      send_data(
        converter.output_data,
        filename: converter.output_filename,
        type: converter.output_filetype,
        disposition: 'attachment'
      )
    else
      raise "Unexpected PaperConverter: #{converter}"
    end
  end

  private

  def converter
    @converter ||= PaperConverters::PaperConverter.make(
      versioned_text,
      export_format,
      current_user
    )
  end

  def export_format
    params[:export_format]
  end

  def paper
    @paper ||= Paper.find_by_id_or_short_doi(params.require(:id))
  end

  def versioned_text_id_param
    params[:versioned_text_id]
  end

  def versioned_text
    @versioned_text ||= begin
      if versioned_text_id_param
        VersionedText.find_by!(
          id: versioned_text_id_param,
          paper: paper
        )
      else
        paper.latest_version
      end
    end
  end
end
