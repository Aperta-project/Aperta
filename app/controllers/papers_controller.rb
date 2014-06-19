class PapersController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  layout 'ember'

  respond_to :json

  def show
    respond_to do |format|
      format.html do
        render 'ember/index'
      end

      format.json do
        render json: paper
      end
    end
  end

  def create
    respond_with PaperFactory.create(paper_params, current_user)
  end

  def edit
    render 'ember/index'
  end

  def update
    if paper.update(paper_params)
      head 204
    else
      # Ember doesn't re-render the paper if there is an error.
      # e.g. Fails to update on adding new authors, but new authors stay in
      # memory client side even though they aren't persisted in the DB.
      respond_with paper
    end
  end

  def upload
    DownloadManuscript.enqueue params[:id], params[:url]
    head :no_content
  end

  def download
    respond_to do |format|
      format.html do
        epub = EpubConverter.convert paper, current_user
        send_data epub[:stream].string, filename: epub[:file_name], disposition: 'attachment'
      end

      format.pdf do
        send_data PDFConverter.convert(paper, current_user),
                  filename: paper.display_title.parameterize("_"),
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
    end
  end

  private

  def paper_params
    params.require(:paper).permit(
      :short_title, :title, :abstract,
      :body, :paper_type, :submitted,
      :journal_id,
      authors: [:first_name, :middle_initial, :last_name, :title, :affiliation, :secondary_affiliation, :department, :email, :deceased, :corresponding_author],
      declaration_ids: [],
      reviewer_ids: [],
      phase_ids: [],
      assignee_ids: [],
      editor_ids: [],
      figure_ids: []
    )
  end

  def paper
    Paper.find(params[:id]) if params[:id]
  end

  def enforce_policy
    authorize_action!(paper: paper)
  end
end
