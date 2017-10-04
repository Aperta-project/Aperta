# Provides a template context for the Sendback Reasons Letter Template
class SendbacksScenario < TemplateScenario
  # def self.complex_merge_fields
  #   [{ name: :task, context: SendbacksContext }]
  # end

  def intro
    task.answer_for('tech-check-email--email-intro').value
  end

  def footer
    task.answer_for('tech-check-email--email-footer').value
  end

  def sendback_reasons
    reasons = task.answers.select do |answer|
      content = CardContent.find answer.card_content_id
      parent = CardContent.find content.parent_id
      parent.content_type == 'sendback-reason' && content.content_type != 'check-box'
    end

    reasons.map(&:value)
  end

  private

  def task
    @object
  end
end
