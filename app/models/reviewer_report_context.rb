class ReviewerReportContext < TemplateContext
  include ActionView::Helpers::SanitizeHelper

  whitelist :state, :revision, :status, :datetime, :invitation_accepted?, :due_at
  context :reviewer, type: :user, source: 'object.user'
  context :answers,  type: :answer, many: true

  def reviewer_number
    object.task.reviewer_number
  end

  def reviewer_name
    strip_tags(answers.detect { |a| a.ident.ends_with?('--identity') }.try(:value))
  end

  def due_at
    object.due_at.to_s(:due_with_hours)
  end

  def rendered_answer_idents
    [
      'front_matter_reviewer_report--suitable--comment',
      'front_matter_reviewer_report--includes_unpublished_data--explanation',
      'reviewer_report--comments_for_author'
    ]
  end

  def rendered_answers
    rendered_answer_idents.map { |ident| answers.find { |answer| answer.ident == ident } }
      .compact
  end
end
