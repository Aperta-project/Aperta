class JIRAIntegrationWorker
  include Sidekiq::Worker

  def perform(user_full_name, feedback_params)
    JIRAIntegrationService.create_issue(user_full_name, feedback_params)
  end
end
