class FiguresController < ApplicationController
  before_action :load_paper, only: :create
  before_action :authenticate_user!

  def create
    figures = Array.wrap(figure_params.delete(:attachment))

    new_figures = figures.map do |figure|
      @paper.figures.create(figure_params.merge(attachment: figure))
    end

    respond_to do |f|
      f.html { redirect_to edit_paper_path @paper }
      f.json { render json: new_figures }
    end
  end

  def destroy
    f = current_user.figures.find(params[:id])
    f.destroy
    head :ok
  end

  private

  def load_paper
    @paper = Paper.find(params[:paper_id])
  end

  def figure_params
    params.require(:figure).permit(:attachment, attachment: [])
  end
end
