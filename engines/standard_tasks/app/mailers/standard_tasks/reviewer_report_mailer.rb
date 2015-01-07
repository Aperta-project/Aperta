module StandardTasks
  class ReviewerReportMailer < ActionMailer::Base
    include Rails.application.routes.url_helpers

    default from: ENV.fetch('FROM_EMAIL')

    def notify_editor_email(task:, recipient:)
      @recipient = recipient
      @task = task
      @paper = task.paper

      mail(to: recipient.email,
           subject: "Reviewer has completed the review on Tahi")
    end
  end
end
