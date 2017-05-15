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

    reviewer_report.submit! if reviewer_report_params[:submitted].present?

    render json: reviewer_report
  end

  private

  def reviewer_report
    @reviewer_report ||= ReviewerReport.find(params[:id])
  end

  def reviewer_report_params
    params.require(:reviewer_report)
      .permit(:submitted)
  end
end
