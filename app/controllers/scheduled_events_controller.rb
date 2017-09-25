class ScheduledEventsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def update
    scheduled_event = ScheduledEvent.find(params[:id])
    scheduled_event.switch_on! if params[:state] == 'active'
    scheduled_event.switch_off! if params[:state] == 'passive'
    render json: scheduled_event
  end

  private

  def scheduled_event_params
    params.permit(:state)
  end
end
