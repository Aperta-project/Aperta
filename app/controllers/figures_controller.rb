class FiguresController < ApplicationController
  respond_to :json
  before_action :authenticate_user!
  before_action :enforce_policy, except: [:create]
  before_action :enforce_policy_on_create, only: [:create]

  def create
    new_figure = paper.figures.create status: "processing"
    DownloadFigureWorker.perform_async(new_figure.id, params[:url])
    render json: new_figure
  end

  def update
    figure = Figure.find params[:id]
    figure.update_attributes figure_params

    respond_with figure
  end

  def update_attachment
    figure = Figure.find(params[:id])
    figure.update_attribute(:status, "processing")
    DownloadFigureWorker.perform_async(figure.id, params[:url])
    render json: figure
  end

  def destroy
    Figure.find(params[:id]).destroy
    head :no_content
  end

  private

  def paper
    @paper ||= Paper.find(params[:paper_id])
  end

  def enforce_policy
    authorize_action!(resource: Figure.find(params[:id]))
  end

  def enforce_policy_on_create
    figure = paper.figures.new
    authorize_action!(resource: figure)
  end

  def figure_params
    params.require(:figure).permit(:title, :caption, :attachment, attachment: [])
  end

  def render_404
    head 404
  end
end
