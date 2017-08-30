# Provides a template context for ReviewerReports
class ReviewerReportContext < TemplateContext
  def self.complex_merge_fields
    [{ name: :reviewer, context: UserContext },
     { name: :answers, context: AnswerContext, many: true }]
  end

  def self.blacklisted_merge_fields
    [:computed_status, :computed_datetime]
  end

  whitelist :state, :revision, :computed_status, :computed_datetime, :invitation_accepted?, :due_at

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
