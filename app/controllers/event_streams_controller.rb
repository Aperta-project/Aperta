class EventStreamsController < ApplicationController
  before_action :authenticate_user!
  def show
    render json: EventStream.connection_info(ids).to_json
  end

  def ids
    submitted_ids = current_user.submitted_papers.pluck(:id)
    paper_role_paper_ids = current_user.paper_roles.pluck(:paper_id)
    submitted_ids | paper_role_paper_ids
  end
end
