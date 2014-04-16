class FiguresController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  before_action :authenticate_user!

  def create
    figures = Array.wrap(figure_params.delete(:attachment))

    new_figures = figures.map do |figure|
      paper.figures.create(figure_params.merge(attachment: figure))
    end

    respond_to do |f|
      f.html { redirect_to edit_paper_path paper }
      f.json { render json: new_figures }
    end
  end

  def destroy
    f = current_user.figures.find(params[:id])
    f.destroy
    head :ok
  end

  private

  def paper
    @paper ||= begin
      PaperPolicy.new(params[:paper_id], current_user).paper.tap do |p|
        raise ActiveRecord::RecordNotFound unless p.present?
      end
    end
  end

  def figure_params
    params.require(:figure).permit(:attachment, attachment: [])
  end

  def render_404
    return head 404
  end
end
