class JiraWorker
  include Sidekiq::Worker

  def perform(user_id, feedback_params)
    Jira.create_issue(user_id, feedback_params)
  end
end
