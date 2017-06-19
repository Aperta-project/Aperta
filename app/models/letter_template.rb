# This is meant to hold different types of letter templates for decisions
# and any other use cases where a letter template with variable replacement
# would be useful.
class LetterTemplate < ActiveRecord::Base
  belongs_to :journal

  validates :letter, presence: true
  validates :subject, presence: true

  def render_attr(template, context)
    Liquid::Template.parse(template).render(context)
  end

  def render(context)
    tap do |my|
      # This is just an in-memory edit (render) of the letter template
      # fields that then get passed to the serializer. DO NOT save the
      # rendered versions.
      my.subject = render_attr(subject, context)
      my.to = render_attr(to, context)
      my.letter = render_attr(letter, context)
    end
  end
end
