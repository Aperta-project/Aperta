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
    else
      paper.update(paper_params)
    end
    respond_with paper
  end

  def upload
    manuscript = paper.manuscript || paper.build_manuscript
    manuscript.update_attribute :status, "processing"
    DownloadManuscript.enqueue manuscript.id, params[:url]
    render json: paper
  end

  def heartbeat
    if paper.locked?
      paper.heartbeat! # update heartbeat timestamp
      # remove any unlock jobs for this paper
      # schedule an unlock two minutes from now
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
      :body, :paper_type, :submitted,
      :journal_id,
      :locked_by_id,
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
    @paper ||= Paper.find(params[:id]) if params[:id]
  end

  def enforce_policy
    authorize_action!(paper: paper)
  end

  def sanitize_title
    strip_tags!(params[:paper], :title)
  end
end
