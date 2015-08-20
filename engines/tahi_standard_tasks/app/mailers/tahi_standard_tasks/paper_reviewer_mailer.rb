module TahiStandardTasks
  class PaperReviewerMailer < ActionMailer::Base
    include Rails.application.routes.url_helpers
    add_template_helper ClientRouteHelper
    layout "mailer"

    default from: ENV.fetch('FROM_EMAIL', 'no-reply@example.com')

    def notify_invited(invitation_id:)
      @invitation = Invitation.find(invitation_id)
      @invitee = @invitation.invitee
      @paper = @invitation.paper
      @task = @invitation.task

      subject = "You have been invited as a reviewer for the manuscript, \"#{@paper.display_title}\""
      mail(to: @invitation.email, subject: subject)
    end

    def notify_rescission(recipient_email:, recipient_name:, paper_id:)
      @recipient_name = recipient_name
      @paper = Paper.find(paper_id)

      subject = "Your invitation to be a reviewer has been rescinded for the manuscript, \"#{@paper.display_title}\""
      mail(to: recipient_email, subject: subject)
    end
  end
end
