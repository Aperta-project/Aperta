class EventStreamsController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: EventStreamConnection.new
  end
end
