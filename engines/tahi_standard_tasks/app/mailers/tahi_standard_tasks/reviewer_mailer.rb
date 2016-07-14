module TahiStandardTasks
  class ReviewerMailer < ActionMailer::Base
    include Rails.application.routes.url_helpers
    include MailerHelper
    add_template_helper ClientRouteHelper
    add_template_helper TemplateHelper
    layout "mailer"

    default from: Rails.configuration.from_email

    def reviewer_accepted(invite_reviewer_task_id:, reviewer_id:, assigner_id:)
      @assigner = User.find_by(id: assigner_id)
      @reviewer = User.find_by(id: reviewer_id)

      return unless @assigner.present? && @reviewer.present?

      @invite_reviewer_task = Task.find(invite_reviewer_task_id)
      @paper = @invite_reviewer_task.paper
      @journal = @paper.journal

      mail(to: @assigner.email, subject: "Reviewer invitation was accepted on the manuscript, \"#{@paper.display_title}\"")
    end

    def reviewer_declined(invite_reviewer_task_id:, invitation_id:,
      reviewer_id:, assigner_id:)

      @assigner = User.find_by(id: assigner_id)
      @reviewer = User.find_by(id: reviewer_id)
      @invitation = Invitation.find_by(id: invitation_id)

      return unless @assigner.present? && @reviewer.present?

      @invite_reviewer_task = Task.find(invite_reviewer_task_id)
      @paper = @invite_reviewer_task.paper
      @journal = @paper.journal

      mail(to: @assigner.email, subject: "Reviewer invitation was declined on the manuscript, \"#{@paper.display_title}\"")
    end

    def welcome_reviewer(assignee_id:, paper_id:)
      @paper = Paper.find(paper_id)
      @journal = @paper.journal
      assignee = User.find_by(id: assignee_id)
      @assignee_name = display_name(assignee)

      mail(
        to: assignee.try(:email),
        subject: "Thank you for agreeing to review for #{@journal.name}")
    end
  end
end
