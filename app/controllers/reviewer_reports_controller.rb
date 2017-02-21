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

  def create
    task = Task.find(reviewer_report_params[:task_id])
    requires_user_can :edit, task

    # TODO APERTA-9226 need to assign the appropriate card here
    # based on the type of task.  reports belonging to a ReviewerReportTask will
    # get the card named 'ReviewerReport', etc for FrontMatterReviewerReport
    reviewer_report = ReviewerReport.new(task: task,
                                         decision: task.paper.draft_decision,
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
