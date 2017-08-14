##
# Controller for handling reviewer reports
#
# A reviewer report owns the nested question answers for a given review
#
class ReviewerReportsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    requires_user_can :edit, reviewer_report.task
    render json: reviewer_report
  end

  def update
    requires_user_can :edit, reviewer_report.task

    if FeatureFlag[:REVIEW_DUE_DATE]
      reviewer_report.due_datetime.update_attributes reviewer_report_params.slice(:due_at)
      reviewer_report.schedule_events if FeatureFlag[:REVIEW_DUE_AT]
    end
    reviewer_report.submit! if reviewer_report_params[:submitted].present?

    # return the updated report if the due date changed
    if reviewer_report_params.slice(:due_at)
      render json: reviewer_report
    else
      respond_with reviewer_report
    end
  end

  private

  def reviewer_report
    @reviewer_report ||= ReviewerReport.find(params[:id])
  end

  def reviewer_report_params
    params.require(:reviewer_report)
      .permit(:submitted, :due_at)
  end
end
