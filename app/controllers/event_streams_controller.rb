class EventStreamsController < ApplicationController
  protect_from_forgery except: :auth

  before_action :authenticate_user!

  def show
    render json: EventStreamConnection.new
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
    @connection ||= EventStreamConnection.new
  end
end
