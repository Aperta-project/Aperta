##
# Controller for handling reviewer reports
#
# A reviewer reports owns the nested question answers for a given review
#
class ReviewerReportsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    requires_user_can :edit, reviewer_report.task
    render json: reviewer_report
  end

  def create
    task = Task.find(reviewer_report_params[:task_id])
    requires_user_can :edit, task

    reviewer_report = ReviewerReport.new(task: task,
                                         decision: task.decision,
                                         user: current_user)
    reviewer_report.save!

    render json: reviewer_report
  end

  def update
    requires_user_can :edit, reviewer_report.task
    reviewer_report.update!(reviewer_report_params)

    render json: reviewer_report
  end

  def destroy
    requires_user_can :edit, reviewer_report.task
    reviewer_report.destroy!

    render json: reviewer_report
  end

  private

  def reviewer_report
    @reviewer_report ||= ReviewerReport.find(params[:id])
  end

  def reviewer_report_params
    params.require(:reviewer_report)
          .permit(:task_id)
  end
end
