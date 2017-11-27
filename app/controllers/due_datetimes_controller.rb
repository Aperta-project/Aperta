##
# Controller for due datetime
##
class DueDatetimesController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def update
    if FeatureFlag[:REVIEW_DUE_DATE]
      requires_user_can :edit_due_date, due_datetime.due.task
      due_datetime.update_attributes due_datetime_params
      due_datetime.due.schedule_events if FeatureFlag[:REVIEW_DUE_AT]
      render json: due_datetime
    end
  end

  private

  def due_datetime
    @due_datetime ||= DueDatetime.find(params[:id])
  end

  def due_datetime_params
    params.require(:due_datetime).permit(:due_at)
  end
end
