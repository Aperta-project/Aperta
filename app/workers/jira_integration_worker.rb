class JIRAIntegrationWorker
  include Sidekiq::Worker

  def perform(user_id, feedback_params)
    JIRAIntegrationService.create_issue(user_id, feedback_params)
  end
end
