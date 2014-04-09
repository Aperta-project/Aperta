class EventStreamsController < ApplicationController
  before_action :authenticate_user!
  def show
    render json: EventStream.connection_info(paper_ids).to_json
  end

  def paper_ids
    current_user.papers.map &:id
  end
end
