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
        to:      @invitation.email,
        subject: @subject,
        bcc:     @paper.journal.reviewer_email_bcc
      )
    end

    def reviewer_accepted(invitation_id:)
      @invitation = Invitation.find_by(id: invitation_id)
      return if @invitation.blank?

      @assigner = @invitation.inviter
      return if @assigner.blank?

      @invite_reviewer_task = @invitation.task
      @paper = @invite_reviewer_task.paper
      @journal = @paper.journal

      @reviewer = @invitation.invitee
      @reviewer_name = @reviewer.try(:full_name) || @invitation.email

      mail(
        to: @assigner.email,
        subject: "Reviewer invitation was accepted on the manuscript, \"#{@paper.display_title}\""
      )
    end

    def reviewer_declined(invitation_id:)
      @invitation = Invitation.find_by(id: invitation_id)
      return if @invitation.blank?

      @assigner = @invitation.inviter
      return if @assigner.blank?

      @invite_reviewer_task = @invitation.task
      @paper = @invite_reviewer_task.paper
      @journal = @paper.journal

      @reviewer = @invitation.invitee
      @reviewer_name = @reviewer.try(:full_name) || @invitation.email

      mail(
        to: @assigner.email,
        subject: "Reviewer invitation was declined on the manuscript, \"#{@paper.display_title}\""
      )
    end

    def welcome_reviewer(assignee_id:, paper_id:)
      @paper = Paper.find(paper_id)
      @journal = @paper.journal
      @assignee = User.find_by(id: assignee_id)
      @assignee_name = display_name(@assignee)
      @reviewer_report =
        ReviewerReport.where(user: @assignee,
                             decision: @paper.draft_decision).first
      @review_due_at = @reviewer_report.due_at || 10.days.from_now
      @invitation = @reviewer_report.invitation
      mail(
        to: @assignee.try(:email),
        subject: "Thank you for agreeing to review for #{@journal.name}"
      )
    end

    def remind_before_due(reviewer_report_id:)
      reminder_notice(letter_template_ident: 'review-reminder-before-due', reviewer_report_id: reviewer_report_id)
    end

    def first_late_notice(reviewer_report_id:)
      reminder_notice(letter_template_ident: 'review-reminder-first-late', reviewer_report_id: reviewer_report_id)
    end

    def second_late_notice(reviewer_report_id:)
      reminder_notice(letter_template_ident: 'review-reminder-second-late', reviewer_report_id: reviewer_report_id)
    end

    def thank_reviewer(reviewer_report_id:)
      @reviewer_report = ReviewerReport.find(reviewer_report_id)
      @paper = @reviewer_report.paper
      @journal = @paper.journal
      @letter_template = @journal.letter_templates.find_by(ident: 'reviewer-appreciation')
      begin
        @letter_template.render(ReviewerReportScenario.new(@reviewer_report), check_blanks: true)
        @subject = @letter_template.subject
        @body = @letter_template.body
        @to = @reviewer_report.user.email
        @cc = @letter_template.cc
        @bcc = @letter_template.bcc
        mail(to: @to, cc: @cc, bcc: @bcc, subject: @subject)
      rescue BlankRenderFieldsError => e
        Bugsnag.notify(e)
      end
    end

    private

    def reminder_notice(letter_template_ident:, reviewer_report_id:)
      @reviewer_report = ReviewerReport.find(reviewer_report_id)
      @paper = @reviewer_report.paper
      @journal = @paper.journal
      @letter_template = @journal.letter_templates.find_by(ident: letter_template_ident)
      @invitation = @reviewer_report.invitation
      begin
        @letter_template.render(ReviewerReportScenario.new(@reviewer_report), check_blanks: true)
        @subject = @letter_template.subject
        @body = @letter_template.body
        @to = @reviewer_report.user.email
        @cc = @letter_template.cc
        @bcc = @letter_template.bcc
        mail(to: @to, cc: @cc, bcc: @bcc, subject: @subject, template_name: 'review_due_reminder')
      rescue BlankRenderFieldsError => e
        Bugsnag.notify(e)
      end
    end
  end
end
