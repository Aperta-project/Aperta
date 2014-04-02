class PapersController < ApplicationController
  before_filter :authenticate_user!

  def show
    respond_to do |format|
      @paper = PaperPolicy.new(params[:id], current_user).paper
      raise ActiveRecord::RecordNotFound unless @paper

      format.html do
        redirect_to edit_paper_path(@paper) unless @paper.submitted?
        @tasks = TaskPolicy.new(@paper, current_user).tasks
      end

      format.json do
        render json: @paper
      end
    end
  end

  def new
    @paper = Paper.new
  end

  def create
    @paper = current_user.papers.create!(paper_params)
    render json: @paper
  end

  def edit
    @paper = PaperPolicy.new(params[:id], current_user).paper
    redirect_to paper_path(@paper) if @paper.submitted?
    @tasks = TaskPolicy.new(@paper, current_user).tasks
  end

  def update
    @paper = Paper.find(params[:id])
    if @paper.update paper_params
      PaperRole.where(user_id: paper_params[:reviewer_ids]).update_all reviewer: true
      head 200
    else
      # Ember doesn't re-render the paper if there is an error.
      # e.g. Fails to update on adding new authors, but new authors stay in
      # memory client side even though they aren't persisted in the DB.
      render status: 500
    end
  end

  def upload
    @paper = Paper.find(params[:id])

    manuscript_data = DocumentParser.parse(params[:upload_file].path)
    @paper.update manuscript_data
    head :no_content
  end

  private

  def paper_params
    params.require(:paper).permit(
      :short_title, :title, :abstract,
      :body, :paper_type, :submitted,
      :decision, :decision_letter,
      :journal_id,
      authors: [:first_name, :last_name, :affiliation, :email],
      declaration_ids: [],
      reviewer_ids: [],
      phase_ids: [],
      assignee_ids: [],
      editor_ids: [],
      figure_ids: []
    )
  end
end
