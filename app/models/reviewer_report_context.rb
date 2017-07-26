# Provides a template context for ReviewerReports
class ReviewerReportContext < TemplateContext
  whitelist :state, :revision, :computed_status, :computed_datetime,
            :invitation_accepted?, :due_at

  alias status computed_status
  alias datetime computed_datetime

  def reviewer
    UserContext.new(@object.user)
  end

  def reviewer_number
    @object.task.reviewer_number
  end

  def answers
    @object.answers.map { |a| AnswerContext.new(a) }
  end
end
