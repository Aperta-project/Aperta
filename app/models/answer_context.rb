# Provides a template context for Answers
class AnswerContext < TemplateContext
  whitelist :value_type, :children, :string_value, :value

  def question
    @object.card_content.text
  end

  def ident
    @object.card_content.ident
  end
end
