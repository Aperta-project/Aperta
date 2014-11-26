class StreamsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def show
    payload = Sidekiq.redis do |redis|
      redis.get("event_stream::#{current_user.id}::#{params[:id]}")
    end
    render json: payload
  end
end
