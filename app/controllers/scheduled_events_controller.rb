class ScheduledEventsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def update
    permitted = params.require(:scheduled_event).permit(:state)
    scheduled_event = ScheduledEvent.find(params[:id])
    owner = scheduled_event.due_datetime.due
    # because this is only used by ReviewerReport
    # but ideally this would be a relationship directly on a task
    requires_user_can(:edit, (owner.try(:task) || owner))
    scheduled_event.switch_on! if permitted[:state] == 'active'
    scheduled_event.switch_off! if permitted[:state] == 'passive'
    render json: scheduled_event
  end
end
