class ScheduledEventsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def active
    scheduled_event.switch_on!
    render json: event
  end

  def passive
    scheduled_event.switch_off!
    render json: event
  end

  private

  def scheduled_event
    ScheduledEvent.find(params[:id])
  end
end
