class PapersController < ApplicationController
  def new
    @paper = Paper.new
  end

  def create
    @paper = Paper.new(paper_params)

    if @paper.save
      redirect_to edit_paper_path @paper
    end
  end

  def edit
    @paper = Paper.find(params[:id])
  end

  private
  def paper_params
    params.require(:paper).permit(:short_title)
  end
end
