module TahiStandardTasks
  class RegisterDecisionMailer < ActionMailer::Base
    include Rails.application.routes.url_helpers

    default from: ENV.fetch('FROM_EMAIL')

    def notify_author_email(task_id:)
      @task = Task.find(task_id)
      @paper = @task.paper
      @decision = @paper.decisions.latest
      @recipient = User.find(@paper.user_id)

      mail(to: @recipient.email,
           subject: "A Decision has been Registered on #{@paper.title}")
    end
  end
end
