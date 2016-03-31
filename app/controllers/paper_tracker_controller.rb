# Returns papers being searched for by admins for display in Paper Tracker
class PaperTrackerController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    fail AuthorizationError unless journal_ids.length > 0
    # show all papers that user is connected to across all journals
    papers = order(QueryParser.new(current_user: current_user)
             .build(params[:query] || '')
             .where(journal_id: journal_ids)
             .where.not(publishing_state: :unsubmitted))
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

  def order(query)
    unless params[:orderBy].present?
      return query.reorder("submitted_at #{order_dir}")
    end
    column = params[:orderBy]

    if ["handling_editor", "cover_editor"].include? column
      return order_by_role(query, column.titleize)
    end

    query.reorder("#{column} #{order_dir}")
  end

  def order_by_role(query, role)
    role_ids = Role.where(journal_id: journal_ids, name: role)
               .map(&:id)
               .join(", ")
    query.joins(<<-SQL.strip_heredoc)
        LEFT JOIN assignments
        ON assignments.assigned_to_id = papers.id AND
        assignments.assigned_to_type='Paper' AND
        assignments.role_id IN (#{role_ids})
      SQL
      .joins(<<-SQL.strip_heredoc)
        LEFT JOIN users
        ON users.id = assignments.user_id
      SQL
      .select('papers.*, users.last_name')
      .order("users.last_name #{order_dir}")
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
