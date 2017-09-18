# Provides a template context for ReviewerReports
class ReviewerReportContext < TemplateContext
  include ActionView::Helpers::SanitizeHelper
  def self.complex_merge_fields
    [{ name: :reviewer, context: UserContext },
     { name: :answers, context: AnswerContext, many: true }]
  end

  whitelist :state, :revision, :status, :datetime, :invitation_accepted?, :due_at

  def reviewer
    UserContext.new(@object.user)
  end

  def reviewer_number
    reviewer_report.task.reviewer_number
  end

  def reviewer_name
    strip_tags(answers.detect { |a| a.ident.ends_with?('--identity') }.try(:value))
  end

  def answers
    reviewer_report.answers.map { |a| AnswerContext.new(a) }
  end

  def due_at
    reviewer_report.due_at.to_s(:due_with_hours)
  end

  def rendered_answer_idents
    [
      'front_matter_reviewer_report--includes_unpublished_data--explanation',
      'reviewer_report--comments_for_author'
    ]
  end

  private

  def reviewer_report
    @object
  end
end
