class PapersController < ApplicationController
  before_filter :authenticate_user!

  def new
    @paper = Paper.new
  end

  def create
    @paper = current_user.papers.new(paper_params)

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
