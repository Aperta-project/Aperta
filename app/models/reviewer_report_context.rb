# Provides a template context for ReviewerReports
class ReviewerReportContext < TemplateContext
  def self.complex_merge_fields
    [{ name: :reviewer, context: UserContext },
     { name: :answers, context: AnswerContext, many: true }]
  end

  whitelist :state, :revision, :status, :datetime, :invitation_accepted?, :due_at

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
