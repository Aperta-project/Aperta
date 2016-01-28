# Returns papers being searched for by admins for display in Paper Tracker
class PaperTrackerController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    # show all papers that user is connected to across all journals
    papers = papers_submitted
              .where(journal_id: journal_ids)
              .merge(query_string_relation)
              .reorder("#{order_by} #{order_dir}") # overrides pg_search order
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

  def query_string_relation
    q = params[:query]

    return unless q.present?

    if doi_search?
      Paper.where('doi like ?', "%#{q}%")
    else
      Paper.pg_title_search q
    end
  end

  def doi_search?
    # if only digits are present
    !!params[:query].to_s.match('^\d+$')
  end

  def metadata(papers)
    {
      totalCount: papers.total_count, # needs to be called on relation.page
      perPage: Kaminari.config.default_per_page,
      page: page
    }
  end

  def journal_ids
    current_user.old_roles.pluck(:journal_id).uniq
  end

  def papers_submitted
    # All papers unless it has not yet been submitted for the first time
    Paper.where.not(publishing_state: :unsubmitted)
  end
end
