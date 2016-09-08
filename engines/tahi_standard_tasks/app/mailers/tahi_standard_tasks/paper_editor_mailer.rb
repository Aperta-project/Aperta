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
      @journal = @paper.journal
      @task = @invitation.task
      @invitation.attachments.each do |attachment|
        attachments[attachment.filename] = attachment.file.read
      end
      mail(
        to: @invitation.email,
        subject: "You've been invited as an editor for the manuscript, \"#{@paper.display_title}\""
      )
    end
  end
end
