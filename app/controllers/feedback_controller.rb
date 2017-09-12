class FeedbackController < ApplicationController
  before_action :authenticate_user!

  def create
    if FeatureFlag[:JIRA_INTEGRATION]
      JIRAIntegrationWorker.perform_async(current_user.full_name, feedback_params)
    else
      FeedbackMailer.contact(current_user, feedback_params).deliver_later
    end
    render json: {}, status: :created
  end

  private

  def feedback_params
    params.require(:feedback).permit(:remarks, :referrer, screenshots: [:url, :filename])
  end
end
