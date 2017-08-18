# Provides a template context for Answers
class AnswerContext < TemplateContext
  def self.merge_fields
    [{ name: :value_type },
     { name: :string_value },
     { name: :value },
     { name: :question },
     { name: :ident }]
  end

  whitelist :value_type, :string_value, :value

  def question
    @object.card_content.text
  end

  def ident
    @object.card_content.ident
  end
end
