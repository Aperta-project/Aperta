module TahiStandardTasks
  class ReviewerMailer < ApplicationMailer
    include Rails.application.routes.url_helpers
    include MailerHelper
    add_template_helper ClientRouteHelper
    add_template_helper TemplateHelper
    layout "mailer"

    default from: Rails.configuration.from_email

    def notify_invited(invitation_id:)
      @invitation = Invitation.find(invitation_id)
      @invitee = @invitation.invitee
      @paper = @invitation.paper
      @task = @invitation.task
      @invitation.attachments.each do |attachment|
        attachments[attachment.filename] = attachment.file.read
      end
      @subject = "You have been invited as a reviewer " \
        "for the manuscript, \"#{@paper.display_title}\""
      mail(
        to: @invitation.email,
        subject: @subject,
        bcc: @paper.journal.reviewer_email_bcc
      )
    end

    def reviewer_accepted(invitation_id:)
      @invitation = Invitation.find_by(id: invitation_id)
      return unless @invitation.present?

      @assigner = @invitation.inviter
      return unless @assigner.present?

      @invite_reviewer_task = @invitation.task
      @paper = @invite_reviewer_task.paper
      @journal = @paper.journal

      @reviewer = @invitation.invitee
      @reviewer_name = @reviewer.try(:full_name) || @invitation.email

      mail(to: @assigner.email, subject: "Reviewer invitation was accepted on the manuscript, \"#{@paper.display_title}\"")
    end

    def reviewer_declined(invitation_id:)
      @invitation = Invitation.find_by(id: invitation_id)
      return unless @invitation.present?

      @assigner = @invitation.inviter
      return unless @assigner.present?

      @invite_reviewer_task = @invitation.task
      @paper = @invite_reviewer_task.paper
      @journal = @paper.journal

      @reviewer = @invitation.invitee
      @reviewer_name = @reviewer.try(:full_name) || @invitation.email

      mail(to: @assigner.email, subject: "Reviewer invitation was declined on the manuscript, \"#{@paper.display_title}\"")
    end

    def welcome_reviewer(assignee_id:, paper_id:)
      @paper = Paper.find(paper_id)
      @journal = @paper.journal
      @assignee = User.find_by(id: assignee_id)
      @assignee_name = display_name(@assignee)
      @reviewer_report =
        ReviewerReport.where(user: @assignee,
                             decision: @paper.draft_decision).first
      @review_due_at = @reviewer_report.due_at.strftime("%B %-d, %Y %H:%M %Z") if @reviewer_report.due_at

      mail(
        to: @assignee.try(:email),
        subject: "Thank you for agreeing to review for #{@journal.name}")
    end
  end
end
