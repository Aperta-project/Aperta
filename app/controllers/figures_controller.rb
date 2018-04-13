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

class FiguresController < ApplicationController
  respond_to :json
  before_action :authenticate_user!

  ## papers/:paper_id/figures
  def index
    paper = Paper.find_by_id_or_short_doi(params[:paper_id])
    requires_user_can(:view, paper)
    respond_with paper.figures
  end

  ## papers/:paper_id/figures
  def create
    paper = Paper.find_by_id_or_short_doi(params[:paper_id])
    requires_user_can(:edit, paper)
    figure = paper.figures.create!
    DownloadAttachmentWorker
      .download_attachment(figure, params[:url], current_user)
    respond_with figure
  end

  def show
    requires_user_can_view(figure)
    respond_with figure
  end

  def update
    requires_user_can(:edit, figure.paper)
    figure.update_attributes figure_params
    render json: figure
  end

  def update_attachment
    requires_user_can(:edit, figure.paper)
    DownloadAttachmentWorker
      .download_attachment(figure, params[:url], current_user)
    render json: figure
  end

  def cancel
    requires_user_can(:edit, figure.paper)
    figure.cancel_download
    head :no_content
  end

  def destroy
    requires_user_can(:edit, figure.paper)
    figure.destroy
    head :no_content
  end

  private

  def figure
    @figure ||= Figure.find(params[:id])
  end

  def figure_params
    params.require(:figure).permit(
      :title,
      :caption,
      :attachment,
      attachment: [])
  end

  def render_404
    head 404
  end
end
