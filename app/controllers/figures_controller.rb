class FiguresController < ApplicationController
  respond_to :json
  before_action :authenticate_user!
  before_action :enforce_policy, except: [:index, :show]

  ## papers/:paper_id/figures
  def index
    respond_with Figure.where(paper_id: params[:paper_id])
  end

  def show
    respond_with figure
  end

  def create
    figure.update_attributes(status: "processing")
    DownloadFigureWorker.perform_async(figure.id, params[:url])
    respond_with figure
  end

  def update
    figure.update_attributes figure_params
    respond_with figure
  end

  def update_attachment
    figure.update_attribute(:status, "processing")
    DownloadFigureWorker.perform_async(figure.id, params[:url])
    render json: figure
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

  def enforce_policy
    authorize_action!(resource: figure)
  end

  def figure_params
    params.require(:figure).permit(:title, :caption, :attachment, attachment: [])
  end

  def render_404
    head 404
  end
end
