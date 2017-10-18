module TahiStandardTasks
  class RegisterDecisionMailer < ApplicationMailer
    include Rails.application.routes.url_helpers
    add_template_helper ClientRouteHelper
    layout "mailer"

    default from: Rails.configuration.from_email

    def notify_author_email(to_field:, subject_field:, decision_id:)
      @decision = Decision.find(decision_id)
      @paper = @decision.paper
      @recipient_email = to_field || @paper.creator.email
      @subject = subject_field || "A decision has been registered on the manuscript, \"#{@paper.display_title}\""

      # for some weird reason mails only get sent to one recipient
      # when all the email addresses are in a string.
      # so we just put all the email addresses into an array manually
      @mails = @recipient_email.split(',').map(&:strip)
      mail(to: @mails,
           subject: @subject)
    end
  end
end
