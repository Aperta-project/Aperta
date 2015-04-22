module TahiStandardTasks
  class ReviewerMailer < ActionMailer::Base
    include Rails.application.routes.url_helpers

    default from: ENV.fetch('FROM_EMAIL')

    def reviewer_accepted(invite_reviewer_task_id:, reviewer_id:, assigner_id:)
      @assigner = User.find(assigner_id)
      @reviewer = User.find(reviewer_id)
      @invite_reviewer_task = Task.find(invite_reviewer_task_id)
      @paper = @invite_reviewer_task.paper
      @journal = @paper.journal

      mail(to: @assigner.email, subject: "Reviewer has accepted reviewer invitation")
    end
  end
end
