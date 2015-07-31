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

      mail({
        to: @invitation.email,
        subject: "You have been invited as a reviewer for the manuscript, \"#{@paper.display_title}\""
      })
    end

    def notify_rescission(code:)
      @invitation = Invitation.where(code: code).first
      @invitee = @invitation.invitee
      @paper = @invitation.paper

      mail({
        to: @invitation.email,
        subject: "Your invitation to be a reviewer has been rescinded for the manuscript, \"#{@paper.display_title}\""
      })
    end
  end
end
