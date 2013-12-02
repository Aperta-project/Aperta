class FiguresController < ApplicationController
  before_action :load_paper
  before_action :authenticate_user!

  def create
    @paper.figures.create(figure_params)
    redirect_to edit_paper_path @paper
  end

  private

  def load_paper
    @paper = Paper.find(params[:paper_id])
  end

  def figure_params
    params.require(:figure).permit(:attachment)
  end
end
