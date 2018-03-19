class ScheduledEventsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def update
    permitted = params.require(:scheduled_event).permit(:state)
    scheduled_event = ScheduledEvent.find(params[:id])
    owner = scheduled_event.due_datetime.due
    # Ideally this would be a relationship directly on a task, le sigh
    requires_user_can(:edit, (owner.is_a?(Task) ? owner : owner.task))
    scheduled_event.switch_on! if permitted[:state] == 'active'
    scheduled_event.switch_off! if permitted[:state] == 'passive'
    render json: scheduled_event
  end
end
