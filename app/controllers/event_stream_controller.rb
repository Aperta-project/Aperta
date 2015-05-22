class EventStreamController < ApplicationController
  protect_from_forgery except: :auth

  before_action :authenticate_user!

  def auth
    if channel.authorized?(user: current_user)
      render json: channel.authenticate(socket_id: params[:socket_id])
    else
      head 403
    end
  end

  private

  def channel
    @channel ||= TahiPusher::Channel.new(channel_name: params[:channel_name])
  end
end
