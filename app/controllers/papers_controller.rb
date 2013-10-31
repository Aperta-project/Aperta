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

  def update
    @paper = Paper.find(params[:id])

    if @paper.update paper_params
      redirect_to root_path
    end
  end

  def upload
    @paper = Paper.find(params[:id])

    manuscript_data = DocumentParser.parse(params[:upload_file].path)
    @paper.update manuscript_data
    redirect_to edit_paper_path(@paper)
  end

  private

  def paper_params
    params.require(:paper).permit(:short_title, :title, :abstract, :body)
  end
end
