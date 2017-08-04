# This is meant to hold different types of letter templates for decisions
# and any other use cases where a letter template with variable replacement
# would be useful.
class LetterTemplate < ActiveRecord::Base
  belongs_to :journal

  validates :body, presence: true
  validates :subject, presence: true

  def render(context)
    tap do |my|
      # This is just an in-memory edit (render) of the letter template
      # fields that then get passed to the serializer. DO NOT save the
      # rendered versions.
      my.subject = render_attr(subject, context, sanitize: true)
      my.to = render_attr(to, context, sanitize: true)
      my.body = render_attr(body, context)
    end
  end

  private

  def render_attr(template, context, sanitize: false)
    raw = Liquid::Template.parse(template).render(context)
    if sanitize
      ActionView::Base.full_sanitizer.sanitize(raw)
    else
      raw
    end
  end
end
