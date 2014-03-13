class EventStreamsController < ApplicationController
  def show
    render json: EventStream.connection_info(params[:id]).to_json
  end
end
