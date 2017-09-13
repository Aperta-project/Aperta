class FeedbackController < ApplicationController
  before_action :authenticate_user!

  def create
    FeedbackMailer.contact(current_user, feedback_params).deliver_later
    JIRAIntegrationWorker.perform_async(current_user.full_name, feedback_params[:remarks]) if FeatureFlag[:JIRA_INTEGRATION]
    render json: {}, status: :created
  end

  private

  def feedback_params
    params.require(:feedback).permit(:remarks, :referrer, screenshots: [:url, :filename])
  end
end
