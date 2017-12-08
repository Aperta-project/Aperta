class ScheduledEventsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def update
    permitted = params.require(:scheduled_event).permit(:state)
    scheduled_event = ScheduledEvent.find(params[:id])
    scheduled_event.switch_on! if permitted[:state] == 'active'
    scheduled_event.switch_off! if permitted[:state] == 'passive'
    render json: scheduled_event
  end
end
