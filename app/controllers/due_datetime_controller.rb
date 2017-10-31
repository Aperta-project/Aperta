##
# Controller for due datetime
##
class DueDatetimeController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def update
    requires_user_can :edit_due_date, reviewer_report.task
    due_at_date = reviewer_report_params.slice(:due_at)
    reviewer_report.due_datetime.update_attributes due_at_date

    render json: reviewer_report
  end

  private

  def reviewer_report
    @reviewer_report ||= ReviewerReport.find(params[:id])
  end

  def reviewer_report_params
    params.require(:reviewer_report)
      .permit(:due_at)
  end
end
