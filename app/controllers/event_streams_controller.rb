class EventStreamsController < ApplicationController
  before_action :authenticate_user!
  def show
    render json: EventStream.connection_info(ids).to_json
  end

  def ids
    current_user.journals.pluck(:id)
  end
end
