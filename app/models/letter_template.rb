# This is meant to hold different types of letter templates for decisions
# and any other use cases where a letter template with variable replacement
# would be useful.
class LetterTemplate < ActiveRecord::Base
  belongs_to :journal

  validates :body, presence: true
  validates :subject, presence: true
  validate :template_scenario?
  validate :body_ok?
  validate :subject_ok?

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

  def merge_fields
    scenario.constantize.merge_fields
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

  def template_scenario?
    scenario_class = begin
      scenario.constantize
    rescue NameError
      false
    end
    return if scenario_class && scenario_class < TemplateScenario

    errors.add(:scenario, 'must name a subclass of TemplateScenario')
  end

  def body_ok?
    Liquid::Template.parse(body, error_mode: :warn)
  rescue Liquid::SyntaxError => e
    errors.add(:body, e.message.gsub(/^Liquid syntax error:/, '').strip)
  end

  def subject_ok?
    Liquid::Template.parse(subject, error_mode: :warn)
  rescue Liquid::SyntaxError => e
    errors.add(:subject, e.message.gsub(/^Liquid syntax error:/, '').strip)
  end
end
