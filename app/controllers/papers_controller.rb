class PapersController < ApplicationController
  before_filter :authenticate_user!

  def show
    @assigned_tasks = current_user.tasks
    @paper = PaperPolicy.new(params[:id], current_user).paper
    raise ActiveRecord::RecordNotFound unless @paper
    redirect_to edit_paper_path(@paper) unless @paper.submitted?
  end

  def new
    @paper = Paper.new
  end

  def create
    @paper = current_user.papers.new(paper_params)

    if @paper.save
      redirect_to edit_paper_path @paper
    else
      render :new
    end
  end

  def edit
    @paper = Paper.find(params[:id])
    redirect_to paper_path(@paper) if @paper.submitted?
  end

  def update
    @paper = Paper.find(params[:id])
    params[:paper][:authors] = JSON.parse params[:paper][:authors] if params[:paper].has_key? :authors

    if @paper.update paper_params
      respond_to do |f|
        f.html { redirect_to root_path }
        f.json { head :no_content }
      end
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
    params.require(:paper).permit(:short_title, :title, :abstract, :body, :paper_type, :submitted, :journal_id, declarations_attributes: [:id, :answer], authors: [:first_name, :last_name, :affiliation, :email])
  end
end
