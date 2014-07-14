class EventStreamsController < ApplicationController
  before_action :authenticate_user!
  def show
    render json: EventStream.connection_info(current_user.accessible_paper_ids).to_json
  end
end
