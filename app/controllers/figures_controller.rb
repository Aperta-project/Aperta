class FiguresController < ApplicationController
  respond_to :json
  before_action :authenticate_user!

  ## papers/:paper_id/figures
  def index
    requires_user_can(:view, paper)
    respond_with paper.figures
  end

  def show
    requires_user_can(:view, paper)
    respond_with figure
  end

  def create
    requires_user_can(:edit, paper)
    figure.update_attributes(status: Attachment::STATUS_PROCESSING)
    DownloadAttachmentWorker.perform_async(figure.id, params[:url], current_user.id)
    respond_with figure
  end

  def update
    requires_user_can(:edit, paper)
    figure.update_attributes figure_params
    render json: figure
  end

  def update_attachment
    requires_user_can(:edit, paper)
    figure.update_attribute(:status, Attachment::STATUS_PROCESSING)
    DownloadAttachmentWorker.perform_async(figure.id, params[:url], current_user.id)
    render json: figure
  end

  def cancel
    requires_user_can(:edit, paper)
    figure.cancel_download
    head :no_content
  end

  def destroy
    requires_user_can(:edit, paper)
    figure.destroy
    head :no_content
  end

  private

  def paper
    @paper ||= Paper.find(params[:paper_id])
  end

  def figure
    @figure ||= begin
      if params[:id].present?
        Figure.find(params[:id])
      else
        paper.figures.new
      end
    end
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
