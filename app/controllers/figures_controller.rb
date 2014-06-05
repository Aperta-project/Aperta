class FiguresController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  before_action :authenticate_user!

  def create
    filename = params[:url].split("%2F").last
    new_figure = paper.figures.new
    new_figure.attachment.download! params[:url]
    new_figure.title = filename
    new_figure.save

    respond_to do |f|
      f.html { redirect_to edit_paper_path paper }
      f.json { render json: new_figure }
    end
  end

  def update
    figure = Figure.find params[:id]
    figure.update_attributes figure_params
    respond_to do |f|
      f.json { render json: figure }
    end
  end

  def destroy
    if paper_policy.paper.present?
      paper.figures.find(params[:id]).destroy
      head :ok
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
    @paper_policy ||= PaperFilter.new(params[:paper_id].presence || figure_paper.id, current_user)
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
