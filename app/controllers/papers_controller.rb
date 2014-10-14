class PapersController < ApplicationController
  include AttrSanitize

  before_action :authenticate_user!
  before_action :enforce_policy
  before_action :sanitize_title, only: [:create, :update]

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
    if paper.locked? && !paper.locked_by?(current_user)
      paper.errors.add(:locked_by_id, "This paper is locked for editing by #{paper.locked_by.full_name}.")
      raise ActiveRecord::RecordInvalid, paper
    end

    unless togglingEditable(paper) || paper.editable?
      paper.errors.add(:editable, "This paper is currently locked for review.")
      raise ActiveRecord::RecordInvalid, paper
    end

    if togglingEditable(paper)
      authorize_action_name!(:toggleEditable, paper: paper)
    end

    unless paper_params.has_key?(:body) && paper_params[:body].nil? # To prevent body-disappearing issue
      paper.update(paper_params)
    end

    respond_with paper
  end

  def upload
    manuscript = paper.manuscript || paper.build_manuscript
    manuscript.update_attribute :status, "processing"
    DownloadManuscriptWorker.perform_async manuscript.id, params[:url]
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

  def paper
    @paper ||= Paper.find(params[:id]) if params[:id]
  end

  def enforce_policy
    authorize_action!(paper: paper)
  end

  def sanitize_title
    strip_tags!(params[:paper], :title)
  end

  def togglingEditable(paper)
    paper_params[:editable].presence && paper_params[:editable] != paper.editable
  end
end
