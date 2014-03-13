class EventStreamsController < ApplicationController
  before_action :authenticate_user!
  def show
    pp = PaperPolicy.new(params[:id], current_user)
    if pp.paper
      render json: EventStream.connection_info(params[:id]).to_json
    else
      head :forbidden
    end
  end
end
