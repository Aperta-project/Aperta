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
    figure = paper.figures.create!(status: 'uploading')
    respond_with figure
  end

  def show
    requires_user_can(:view, figure.paper)
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
      :striking_image,
      :attachment,
      attachment: [])
  end

  def render_404
    head 404
  end
end
