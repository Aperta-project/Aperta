class JIRAIntegrationWorker
  include Sidekiq::Worker

  def perform(user_full_name, remarks)
    JIRAIntegrationService.create_issue(user_full_name, remarks)
  end
end
