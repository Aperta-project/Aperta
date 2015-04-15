module TahiStandardTasks
  class ReviewerReportMailer < ActionMailer::Base
    include Rails.application.routes.url_helpers
    add_template_helper ClientRouteHelper

    default from: ENV.fetch('FROM_EMAIL')

    def notify_editor_email(task_id:, recipient_id:)
      @recipient = User.find(recipient_id)
      @task = Task.find(task_id)
      @paper = @task.paper

      mail(to: @recipient.email,
           subject: "Reviewer has completed the review on Tahi")
    end
  end
end
