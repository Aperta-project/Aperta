# Returns papers being searched for by admins for display in Paper Tracker
class PaperTrackerController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    fail AuthorizationError unless journal_ids.length > 0
    # show all papers that user is connected to across all journals
    papers = QueryParser.new
             .build(params[:query] || '')
             .where(journal_id: journal_ids)
             .where.not(publishing_state: :unsubmitted)
             .reorder("#{order_by} #{order_dir}")
             .page(page)

    respond_with papers,
                 each_serializer: PaperTrackerSerializer,
                 root: 'papers',
                 meta: metadata(papers)
  end

  private

  def page
    params[:page].present? ? params[:page] : 1
  end

  def order_by
    params[:orderBy].present? ? params[:orderBy] : :created_at
  end

  def order_dir
    params[:orderDir].present? ? params[:orderDir] : :asc
  end

  def metadata(papers)
    {
      totalCount: papers.total_count, # needs to be called on relation.page
      perPage: Kaminari.config.default_per_page,
      page: page
    }
  end

  def journal_ids
    current_user.filter_authorized(:view_paper_tracker, Journal).objects
  end

  def papers_submitted
    # All papers unless it has not yet been submitted for the first time
    Paper.where.not(publishing_state: :unsubmitted)
  end
end
