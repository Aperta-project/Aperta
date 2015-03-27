class EventStreamsController < ApplicationController
  layout "application"
  before_action :authenticate_user!

  def new
  end

  def show
    render json: EventStreamConnection.new(current_user)
  end
end
