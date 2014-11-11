class EventStreamsController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: EventStreamConnection.connection_info(current_user).to_json
  end
end
