class PapersController < ApplicationController
  include AttrSanitize
  include Notifications::ActivityBroadcaster

  before_action :authenticate_user!
  before_action :enforce_policy
  before_action :sanitize_title, only: [:create, :update]
  before_action :prevent_update_on_locked!, only: [:update, :toggle_editable, :submit, :upload]

  respond_to :json

  def show
    eager_loaded_models = [
      :figures, :authors, :supporting_information_files, :paper_roles, :journal, :locked_by, :striking_image,
      phases: { tasks: [:questions, :attachments, :participations, :comments] }
    ]
    paper = Paper.includes(eager_loaded_models).find(params[:id])
    respond_with(paper)
  end

  def create
    @paper = PaperFactory.create(paper_params, current_user)
    notify_paper_created! if @paper.valid?
    respond_with(@paper)
  end

  def update
    unless paper.editable?
      paper.errors.add(:editable, "This paper is currently locked for review.")
      raise ActiveRecord::RecordInvalid, paper
    end

    unless update_paper_params.has_key?(:body) && update_paper_params[:body].nil? # To prevent body-disappearing issue
      paper.update(update_paper_params)
    end

    if params[:paper][:locked_by_id].present?
      notify_paper!(event_name: "paper::edited", paper: paper)
    end

    respond_with paper
  end

  # non RESTful routes

  def activity
    # TODO: params[:name] probably needs some securitifications
    activities = Activity.public.where(region_name: params[:name], scope: paper).order(created_at: :desc)
    respond_with activities, each_serializer: ActivitySerializer, root: 'feeds'
  end

  def upload
    IhatJobRequest.new(paper: paper).queue(file_url: params[:url], callback_url: ihat_jobs_url)
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
      format.epub do
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
    if paper.valid?
      notify_paper!(event_name: "paper::created", paper: paper)
      # TODO: uncomment!
      # notify_paper!(event_name: "paper::revised", paper: paper) if paper.revised?
      status = 200
    else
      status = 422
    end
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
    @paper ||= begin
      if params[:id].present?
        Paper.find(params[:id])
      elsif params[:publisher_prefix].present? && params[:suffix].present?
        doi = "#{params[:publisher_prefix]}/#{params[:suffix]}"
        Paper.find_by!(doi: doi)
      end
    end
  end

  def enforce_policy
    authorize_action!(paper: paper)
  end

  def sanitize_title
    strip_tags!(params[:paper], :title)
  end

  def notify_paper!(event_name:, paper:)
    broadcast(event_name: event_name, target: paper, scope: paper, region_name: "paper")
  end

  def prevent_update_on_locked!
    if paper.locked? && !paper.locked_by?(current_user)
      paper.errors.add(:locked_by_id, "This paper is locked for editing by #{paper.locked_by.full_name}.")
      raise ActiveRecord::RecordInvalid, paper
    end
  end
end
