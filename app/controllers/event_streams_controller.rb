class EventStreamsController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: EventStreamConnection.connection_info(streamers).to_json
  end


  private

  def streamers
    [current_user, Paper.find(current_user.accessible_paper_ids)].flatten
  end
end
