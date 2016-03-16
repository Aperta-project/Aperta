class PapersController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy,
                except: [:index, :show, :comment_looks]

  respond_to :json

  def index
    page = (params[:page_number] || 1).to_i
    papers = current_user.filter_authorized(
      :view,
      # TODO: we should also eager load short_title_answer, but if a paper does
      # not have any nested_questiona_answers that breaks the filtered query
      Paper.all.includes(:roles, journal: :creator_role)
    ).objects
    active_papers, inactive_papers = papers.partition(&:active?)
    respond_with(papers, {
      each_serializer: LitePaperSerializer,
      meta: { total_active_papers: active_papers.length,
              total_inactive_papers: inactive_papers.length }
    })
  end

  def show
    paper = Paper.eager_load(
      :supporting_information_files,
      { paper_roles: [:user] },
      :tables,
      :bibitems,
      :journal
    ).find(params[:id])
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

    paper.update(update_paper_params)
    Activity.paper_edited!(paper, user: current_user)

    respond_with paper
  end

  ## SUPPLIMENTAL INFORMATION

  def comment_looks
    comment_looks = paper.comment_looks.where(user: current_user).includes(:task)
    respond_with(comment_looks, root: :comment_looks)
  end

  def versioned_texts
    versions = paper.versioned_texts.includes(:submitting_user).order(updated_at: :desc)
    respond_with versions, each_serializer: VersionedTextSerializer, root: 'versioned_texts'
  end

  def workflow_activities
    feeds = ['workflow', 'manuscript']
    activities = Activity.includes(:user).feed_for(feeds, paper)
    respond_with activities, each_serializer: ActivitySerializer, root: 'feeds'
  end

  def manuscript_activities
    activities = Activity.includes(:user).feed_for('manuscript', paper)
    respond_with activities, each_serializer: ActivitySerializer, root: 'feeds'
  end

  def snapshots
    snapshots = paper.snapshots
    respond_with snapshots,
                 each_serializer: SnapshotSerializer,
                 root: 'snapshots'
  end

  ## CONVERSION

  # Upload a word file for the latest version.
  def upload
    DownloadManuscriptWorker.perform_async(paper.id,
                                           params[:url],
                                           ihat_jobs_url,
                                           paper_id: paper.id,
                                           user_id: current_user.id)
    respond_with paper
  end

  def download
    respond_to do |format|
      format.docx do
        if paper.latest_version.source_url.blank?
          render status: :not_found, nothing: true
        else
          redirect_to paper.latest_version.source_url
        end
      end

      format.epub do
        epub = EpubConverter.new(paper, current_user)
        send_data epub.epub_stream.string,
                  filename: epub.fs_filename,
                  disposition: 'attachment'
      end

      format.pdf do
        pdf = PDFConverter.new(paper, current_user)
        send_data pdf.convert,
                  filename: pdf.fs_filename,
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
    end
  end

  ## EDITING

  def toggle_editable
    paper.toggle!(:editable)
    status = paper.valid? ? 200 : 422
    Activity.editable_toggled!(paper, user: current_user)
    render json: paper, status: status
  end

  ## STATE CHANGES

  def submit
    if paper.gradual_engagement? && paper.unsubmitted?
      paper.initial_submit!
    else
      full_submission
    end
    render json: paper, status: :ok
  end

  def reactivate
    paper.reactivate!
    render json: paper, status: :ok
  end

  def withdraw
    requires_user_can :withdraw, paper
    paper.withdraw! withdrawal_params[:reason]
    render json: paper, status: :ok
  end

  private

  def full_submission
    paper.submit! current_user do
      Activity.paper_submitted! paper, user: current_user
    end
  end

  def withdrawal_params
    params.permit(:reason)
  end

  def paper_params
    params.require(:paper).permit(
      :title, :abstract,
      :body, :paper_type, :submitted, :editable,
      :journal_id,
      :striking_image_id,
      authors: [:first_name, :middle_initial, :last_name, :title, :affiliation,
                :secondary_affiliation, :department, :email],
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
      :title, :abstract,
      :paper_type,
      :journal_id,
      :striking_image_id,
      authors: [:first_name, :middle_initial, :last_name, :title, :affiliation,
                :secondary_affiliation, :department, :email],
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
end
