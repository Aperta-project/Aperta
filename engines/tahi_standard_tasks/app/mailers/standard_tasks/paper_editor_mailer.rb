module TahiStandardTasks
  class PaperEditorMailer < ActionMailer::Base
    include Rails.application.routes.url_helpers

    default from: ENV.fetch('FROM_EMAIL')

    def notify_invited(invitation_id:)
      invitation = Invitation.find(invitation_id)
      @invitee = invitation.invitee
      @paper = invitation.paper

      mail({
        to: invitation.email,
        subject: "You have been invited as an editor in Tahi"
      })
    end
  end
end
