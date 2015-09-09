class PapersController < ApplicationController
  include AttrSanitize

  before_action :authenticate_user!
  before_action :enforce_policy, except: [:index, :show, :comment_looks]
  before_action :sanitize_title, only: [:create, :update]
  before_action :prevent_update_on_locked!, only: [:update, :toggle_editable, :submit, :upload]

  respond_to :json

  def index
    page = (params[:page_number] || 1).to_i
    # TODO: This query should be less weird when dashboard is re-assessed
    unique_paper_roles = PaperRole.most_recent_for(current_user).page(page)
    papers = unique_paper_roles.map(&:paper)
    respond_with(papers, {
      each_serializer: LitePaperSerializer,
      meta: { total_pages: unique_paper_roles.total_pages, total_papers: unique_paper_roles.total_count }
    })
  end

  def show
    rel = Paper.includes([
      :figures, :authors, :supporting_information_files, :paper_roles, :journal, :locked_by, :striking_image,
      phases: { tasks: [:questions, :attachments, :participations, :comments] }
    ])
    paper = rel.find(params[:id])
    authorize_action!(paper: paper)
    respond_with(paper)
  end

  def create
    @paper = PaperFactory.create(paper_params, current_user)
    Activity.paper_created!(paper, user: current_user) if @paper.valid?
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

    Activity.paper_edited!(paper, user: current_user) if params[:paper][:locked_by_id].present?

    respond_with paper
  end

  def comment_looks
    comment_looks = paper.comment_looks.includes(task: :phase).where(user: current_user)
    respond_with(comment_looks, root: :comment_looks)
  end

  def workflow_activities
    feeds = ['workflow', 'manuscript']
    activities = Activity.feed_for(feeds, paper)
    respond_with activities, each_serializer: ActivitySerializer, root: 'feeds'
  end

  def manuscript_activities
    activities = Activity.feed_for('manuscript', paper)
    respond_with activities, each_serializer: ActivitySerializer, root: 'feeds'
  end

  def upload
    IhatJobRequest.new(paper: paper).queue(file_url: params[:url], callback_url: ihat_jobs_url)
    respond_with paper
  end

  def heartbeat
    if paper.locked?
      paper.heartbeat
      PaperUnlockerWorker.perform_async(paper.id, true)
    end
    head :no_content
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
    paper.submit! current_user do
      Activity.paper_submitted! paper, user: current_user
      broadcast_paper_submitted_event
    end

    render json: paper, status: :ok
  end

  def withdraw
    paper.withdraw! withdrawal_params[:reason]
    render json: paper, status: :ok
  end

  private

  def withdrawal_params
    params.permit(:reason)
  end

  def paper_params
    params.require(:paper).permit(
      :short_title, :title, :abstract,
      :body, :paper_type, :submitted, :editable,
      :journal_id,
      :locked_by_id,
      :striking_image_id,
      :editor_mode,
      authors: [:first_name, :middle_initial, :last_name, :title, :affiliation, :secondary_affiliation, :department, :email, :deceased, :corresponding_author],
      reviewer_ids: [],
      phase_ids: [],
      assignee_ids: [],
      editor_ids: [],
      figure_ids: [],
      table_ids: [],
      bibitem_ids: []
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
      :editor_mode,
      authors: [:first_name, :middle_initial, :last_name, :title, :affiliation, :secondary_affiliation, :department, :email, :deceased, :corresponding_author],
      reviewer_ids: [],
      phase_ids: [],
      assignee_ids: [],
      editor_ids: [],
      figure_ids: [],
      table_ids: [],
      bibitem_ids: []
    )
  end

  def paper
    @paper ||= begin
      if params[:id].present?
        Paper.find(params[:id])
      end
    end
  end

  def enforce_policy
    authorize_action!(paper: paper, params: params)
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

  def broadcast_paper_submitted_event
    Notifier.notify(event: "paper:submitted", data: { paper: paper })
    if paper.resubmitted?
      Notifier.notify(event: "paper:resubmitted", data: { paper: paper })
    end
  end

end
