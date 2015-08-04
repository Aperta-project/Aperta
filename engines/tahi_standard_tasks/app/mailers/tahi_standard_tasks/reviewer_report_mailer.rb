module TahiStandardTasks
  class ReviewerReportMailer < ActionMailer::Base
    include Rails.application.routes.url_helpers
    include MailerHelper
    add_template_helper ClientRouteHelper
    add_template_helper TemplateHelper
    layout "mailer"

    default from: Rails.configuration.from_email

    def notify_editor_email(task_id:, recipient_id:)
      @recipient = User.find(recipient_id)
      @task = Task.find(task_id)
      @paper = @task.paper

      mail(to: @recipient.email,
           subject: "A review has been completed for the manuscript, \"#{@paper.display_title}\"")
    end
  end
end
