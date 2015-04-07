class EventStreamsController < ApplicationController
  protect_from_forgery except: :auth

  layout "application"
  before_action :authenticate_user!

  def new
  end

  def show
    render json: EventStreamConnection.new(current_user)
  end

  def auth
    if connection.authorized?(user: current_user, channel_name: params[:channel_name])
      render json: connection.authenticate(socket_id: params[:socket_id], channel_name: params[:channel_name])
    else
      head 403
    end
  end

  private

  def connection
    @connection ||= EventStreamConnection.new(current_user)
  end
end
