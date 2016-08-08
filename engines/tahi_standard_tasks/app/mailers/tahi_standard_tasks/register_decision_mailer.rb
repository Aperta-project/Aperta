module TahiStandardTasks
  class RegisterDecisionMailer < ActionMailer::Base
    include Rails.application.routes.url_helpers
    add_template_helper ClientRouteHelper
    layout "mailer"

    default from: ENV.fetch('FROM_EMAIL', 'no-reply@example.com')

    def notify_author_email(to_field:, subject_field:, decision_id:)
      @decision = Decision.find(decision_id)
      @paper = @decision.paper
      @recipient_email = to_field || @paper.creator.email
      @subject = subject_field || "A decision has been registered on the manuscript, \"#{@paper.display_title}\""

      mail(to: @recipient_email,
           subject: @subject)
    end
  end
end
