# Saves searches that editors use on a regular basis
class PaperTrackerQueriesController < ApplicationController
  before_action :authenticate_user!, :authorize

  respond_to :json

  def index
    queries = PaperTrackerQuery.all
    render(
      json: queries,
      each_serializer: PaperTrackerQuerySerializer,
      root: 'paper_tracker_queries'
    )
  end

  def create
    respond_with PaperTrackerQuery.create(query_params)
  end

  def update
    respond_with query.update(query_params)
  end

  def destroy
    title = query.title
    query.update(deleted: true)
    Rails.logger.info("#{current_user.email} deleted query #{title}")
    head :no_content
  end

  private

  def query
    PaperTrackerQuery.find(params[:id])
  end

  def query_params
    params.require(:paper_tracker_query).permit(:title, :query)
  end

  def journals
    current_user.filter_authorized(
      :view_paper_tracker,
      Journal,
      participations_only: false
    ).objects
  end

  def authorize
    fail AuthorizationError unless journals.length > 0
  end
end
