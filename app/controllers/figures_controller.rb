class FiguresController < ApplicationController
  respond_to :json
  before_action :authenticate_user!

  def create
    new_figure = paper.figures.create status: "processing"
    DownloadFigure.enqueue(new_figure.id, params[:url])
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
    DownloadFigure.enqueue(figure.id, params[:url])
    render json: figure
  end

  def destroy
    if paper_policy.paper.present?
      paper.figures.find(params[:id]).destroy
      head :no_content
    else
      head :forbidden
    end
  end

  private

  def paper
    @paper ||= begin
      paper_policy.paper.tap do |p|
        raise ActiveRecord::RecordNotFound unless p.present?
      end
    end
  end

  def paper_policy
    @paper_policy ||= PaperQuery.new(params[:paper_id].presence || figure_paper.id, current_user)
  end

  def figure_paper
    Figure.find(params[:id]).paper
  end

  def figure_params
    params.require(:figure).permit(:title, :caption, :attachment, attachment: [])
  end

  def render_404
    return head 404
  end
end
