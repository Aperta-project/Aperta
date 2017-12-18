class FeedbackController < ApplicationController
  before_action :authenticate_user!

  def create
    FeedbackMailer.contact(current_user, feedback_params).deliver_later

    if FeatureFlag[:JIRA_INTEGRATION]
      jira_params = {
        browser: "#{browser.name} #{browser.version}",
        platform: "#{browser.platform.name} #{browser.platform.version}"
      }.merge(feedback_params)
      JiraWorker.perform_async(current_user.id, jira_params)
    end

    render json: {}, status: :created
  end

  private

  def feedback_params
    params.require(:feedback).permit(:remarks, :referrer, :paper_id, screenshots: [:url, :filename])
  end
end
