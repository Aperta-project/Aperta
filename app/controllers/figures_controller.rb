class FiguresController < ApplicationController
  before_action :load_paper
  before_action :authenticate_user!

  def create
    figures = Array.wrap(figure_params.delete(:attachment))

    results = figures.map do |figure|
      @paper.figures.create(figure_params.merge(attachment: figure)).access_details
    end

    respond_to do |f|
      f.html { redirect_to edit_paper_path @paper }
      f.json { render json: results }
    end
  end

  private

  def load_paper
    @paper = Paper.find(params[:paper_id])
  end

  def figure_params
    params.require(:figure).permit(:attachment, attachment: [])
  end
end
