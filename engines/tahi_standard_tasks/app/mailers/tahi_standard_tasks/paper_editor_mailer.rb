module TahiStandardTasks
  class PaperEditorMailer < ActionMailer::Base
    include Rails.application.routes.url_helpers
    add_template_helper ClientRouteHelper
    layout "mailer"

    default from: Rails.configuration.from_email

    def notify_invited(invitation_id:)
      @invitation = Invitation.find(invitation_id)
      @invitee = @invitation.invitee
      @paper = @invitation.paper
      @task = @invitation.task

      mail({
        to: @invitation.email,
        subject: "You have been invited as an editor on Tahi"
      })
    end
  end
end
