module TahiStandardTasks
  class ReviewerMailer < ActionMailer::Base
    include Rails.application.routes.url_helpers
    add_template_helper ClientRouteHelper

    layout "mailer"

    default from: ENV.fetch('FROM_EMAIL', 'no-reply@example.com')

    def reviewer_accepted(invite_reviewer_task_id:, reviewer_id:, assigner_id:)
      @assigner = User.find_by(id: assigner_id)
      @reviewer = User.find_by(id: reviewer_id)

      return unless @assigner.present? && @reviewer.present?

      @invite_reviewer_task = Task.find(invite_reviewer_task_id)
      @paper = @invite_reviewer_task.paper
      @journal = @paper.journal

      mail(to: @assigner.email, subject: "Reviewer has accepted reviewer invitation")
    end

    def reviewer_declined(invite_reviewer_task_id:, reviewer_id:, assigner_id:)
      @assigner = User.find_by(id: assigner_id)
      @reviewer = User.find_by(id: reviewer_id)

      return unless @assigner.present? && @reviewer.present?

      @invite_reviewer_task = Task.find(invite_reviewer_task_id)
      @paper = @invite_reviewer_task.paper
      @journal = @paper.journal

      mail(to: @assigner.email, subject: "Reviewer has declined reviewer invitation")
    end
  end
end
