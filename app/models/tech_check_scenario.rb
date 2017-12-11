# Provides a template context for the Sendback Reasons Letter Template
class TechCheckScenario < TemplateContext
  wraps Task
  subcontext  :journal,                        source: [:object, :paper, :journal]
  subcontext  :manuscript,       type: :paper, source: [:object, :paper]
  subcontext  :author,           type: :user,  source: [:object, :paper, :creator]
  subcontexts :sendback_reasons, type: :answer

  def intro
    task.answer_for('tech-check-email--email-intro').value
  end

  def footer
    task.answer_for('tech-check-email--email-footer').value
  end

  def sendback_reasons
    task_sendback_reasons(task)
  end

  def paperwide_sendback_reasons
    incomplete_tech_checks = task.paper.tasks
      .joins(card_version: [card_contents: [:answers]])
      .where(card_contents: { content_type: 'tech-check' })
      .where(answers: { value: 'f' }).group('id')

    incomplete_tech_checks.flat_map { |task| task_sendback_reasons(task) }
  end

  private

  def task_sendback_reasons(task)
    reasons = task.answers.includes(:card_content)
                .where('card_contents.content_type' => 'paragraph-input')
                .select do |answer|

      parent = answer.card_content.parent

      if parent.content_type == 'sendback-reason'
        targets = parent.children.to_ary
        # Dont check the display reason editor value(targets[1]). This should be
        # replaced once we have a tag system for better identifying answers
        targets.delete_at 1
        targets.all? { |child| child.answers.order(created_at: :desc)[0].try(:value) }
      else
        false
      end
    end

    reasons.sort_by(&:card_content_id).map { |reason| AnswerContext.new(reason) }
  end

  def task
    object
  end
end
