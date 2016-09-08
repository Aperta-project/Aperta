class FiguresController < ApplicationController
  respond_to :json
  before_action :authenticate_user!
  before_action :enforce_policy, except: [:index]
  before_action :enforce_index_policy, only: [:index]

  ## papers/:paper_id/figures
  def index
    respond_with paper.figures
  end

  def show
    respond_with figure
  end

  def create
    figure.update_attributes(status: Attachment::STATUS_PROCESSING)
    DownloadAttachmentWorker.perform_async(figure.id, params[:url], current_user.id)
    respond_with figure
  end

  def update
    figure.update_attributes figure_params
    render json: figure
  end

  def update_attachment
    figure.update_attribute(:status, Attachment::STATUS_PROCESSING)
    DownloadAttachmentWorker.perform_async(figure.id, params[:url], current_user.id)
    render json: figure
  end

  def cancel
    case figure.status
    when Attachment::STATUS_PROCESSING
      # delete the figure and let sidekiq deal with it
      #
      # sidekiq still running
      figure.destroy
    when Attachment::STATUS_ERROR
      # clean up from exception in sidekiq
      #
      # sidekiq not running due to exception
      figure.destroy
    when Attachment::STATUS_DONE
      # sidekiq completely done, two ships passing in the night
      # no-op
    end
    head :no_content
  end

  def destroy
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

  def enforce_index_policy
    authorize_action!(resource: nil, for_paper: paper)
  end

  def enforce_policy
    authorize_action!(resource: figure)
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
