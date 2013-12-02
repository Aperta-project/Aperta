class FiguresController < ApplicationController
  before_action :load_paper
  before_action :authenticate_user!

  def create
    figures = Array.wrap(figure_params.delete(:attachment))
    figures.each do |figure|
      @paper.figures.create(figure_params.merge(attachment: figure))
    end
    redirect_to edit_paper_path @paper
  end

  private

  def load_paper
    @paper = Paper.find(params[:paper_id])
  end

  def figure_params
    params.require(:figure).permit(:attachment, attachment: [])
  end
end
