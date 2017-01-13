module TahiStandardTasks
  class PaperReviewerMailer < ApplicationMailer
    include Rails.application.routes.url_helpers
    add_template_helper ClientRouteHelper
    layout "mailer"

    default from: ENV.fetch('FROM_EMAIL', 'no-reply@example.com')

    def notify_invited(invitation_id:)
      @invitation = Invitation.find(invitation_id)
      @invitee = @invitation.invitee
      @paper = @invitation.paper
      @task = @invitation.task
      @invitation.attachments.each do |attachment|
        attachments[attachment.filename] = attachment.file.read
      end

      subject = "You have been invited as a reviewer for the manuscript, \"#{@paper.display_title}\""
      mail(to: @invitation.email,
           subject: subject,
           bcc: @paper.journal.reviewer_email_bcc)
    end
  end
end
