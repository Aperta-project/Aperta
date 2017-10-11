# Provides a template context for the Sendback Reasons Letter Template
class SendbacksContext < TemplateContext
  def self.complex_merge_fields
    [{ name: :manuscript, context: PaperContext },
     { name: :journal, context: JournalContext },
     { name: :author, context: UserContext },
     { name: :sendback_reasons, context: AnswerContext, many: true }]
  end

  def manuscript
    @manuscript ||= PaperContext.new(task.paper)
  end

  def journal
    @journal ||= JournalContext.new(task.journal)
  end

  def intro
    task.answer_for('tech-check-email--email-intro').value
  end

  def footer
    task.answer_for('tech-check-email--email-footer').value
  end

  def author
    UserContext.new(task.paper.creator)
  end

  def sendback_reasons
    reasons = task.answers.select do |answer|
      content = CardContent.find answer.card_content_id
      parent = CardContent.find content.parent_id

      if (parent.content_type == 'sendback-reason') && (content.content_type == 'paragraph-input')
        children = parent.children
        selection = children.all? { |child| child.answers[0].value }
      else
        selection = false
      end
      selection
    end

    reasons.map { |reason| AnswerContext.new(reason) }
  end

  private

  def task
    @object
  end
end
