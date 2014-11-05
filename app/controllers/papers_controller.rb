class PapersController < ApplicationController
  include AttrSanitize

  before_action :authenticate_user!
  before_action :enforce_policy
  before_action :sanitize_title, only: [:create, :update]
  before_action :prevent_update_on_locked!, only: [:update, :toggle_editable, :submit, :upload]

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
    unless paper.editable?
      paper.errors.add(:editable, "This paper is currently locked for review.")
      raise ActiveRecord::RecordInvalid, paper
    end

    unless update_paper_params.has_key?(:body) && update_paper_params[:body].nil? # To prevent body-disappearing issue
      paper.update(update_paper_params)
    end

    respond_with paper
  end

  # non RESTful routes

  def upload
    manuscript = paper.manuscript || paper.build_manuscript
    manuscript.update_attribute :status, "processing"
    DownloadManuscriptWorker.perform_async manuscript.id, params[:url], ihat_job_url(id: ':id')
    render json: paper
  end

  def heartbeat
    if paper.locked?
      paper.heartbeat
      PaperUnlockerWorker.perform_async(paper.id, true)
    end
    respond_with paper
  end

  def download
    respond_to do |format|
      format.html do
        epub = EpubConverter.new paper, current_user
        send_data epub.epub_stream.string, filename: epub.file_name, disposition: 'attachment'
      end

      format.pdf do
        send_data PDFConverter.convert(paper, current_user),
                  filename: paper.display_title.parameterize("_"),
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
    end
  end

  def toggle_editable
    paper.toggle!(:editable)
    status = paper.valid? ? 200 : 422
    render json: paper, status: status
  end

  def submit
    paper.update(submitted: true, editable: false)
    status = paper.valid? ? 200 : 422
    render json: paper, status: status
  end

  private

  def paper_params
    params.require(:paper).permit(
      :short_title, :title, :abstract,
      :body, :paper_type, :submitted, :editable,
      :journal_id,
      :locked_by_id,
      :striking_image_id,
      authors: [:first_name, :middle_initial, :last_name, :title, :affiliation, :secondary_affiliation, :department, :email, :deceased, :corresponding_author],
      reviewer_ids: [],
      phase_ids: [],
      assignee_ids: [],
      editor_ids: [],
      figure_ids: []
    )
  end

  def update_paper_params
    # paper params excluding :submitted and :editable
    params.require(:paper).permit(
      :short_title, :title, :abstract,
      :body, :paper_type,
      :journal_id,
      :locked_by_id,
      :striking_image_id,
      authors: [:first_name, :middle_initial, :last_name, :title, :affiliation, :secondary_affiliation, :department, :email, :deceased, :corresponding_author],
      reviewer_ids: [],
      phase_ids: [],
      assignee_ids: [],
      editor_ids: [],
      figure_ids: []
    )
  end

  def paper
    @paper ||= Paper.find(params[:id]) if params[:id]
  end

  def enforce_policy
    authorize_action!(paper: paper)
  end

  def sanitize_title
    strip_tags!(params[:paper], :title)
  end

  def prevent_update_on_locked!
    if paper.locked? && !paper.locked_by?(current_user)
      paper.errors.add(:locked_by_id, "This paper is locked for editing by #{paper.locked_by.full_name}.")
      raise ActiveRecord::RecordInvalid, paper
    end
  end
end
