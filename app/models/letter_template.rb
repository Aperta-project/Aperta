# This is meant to hold different types of letter templates for decisions
# and any other use cases where a letter template with variable replacement
# would be useful.
class LetterTemplate < ActiveRecord::Base
  belongs_to :journal

  validates :name, presence: { message: "This field is required" }, uniqueness: {
    scope: [:journal_id],
    case_sensitive: false,
    message: "That template name is taken for this journal. Please give your template a new name."
  }

  validates :scenario, presence: { message: "This field is required" }
  validates :body, presence: true
  validates :subject, presence: true
  validate :body_ok?
  validate :subject_ok?

  def render(context, check_blanks: false)
    tap do |my|
      # This is just an in-memory edit (render) of the letter template
      # fields that then get passed to the serializer. DO NOT save the
      # rendered versions.
      my.subject = render_attr(subject, context, sanitize: true, check_blanks: check_blanks)
      my.to = render_attr(to, context, sanitize: true, check_blanks: check_blanks)
      my.body = render_attr(body, context, check_blanks: check_blanks)
    end
  end

  def merge_fields
    scenario.constantize.merge_fields
  end

  private

  def render_attr(template, context, sanitize: false, check_blanks: false)
    raw = Liquid::Template.parse(template)
    if check_blanks && LetterTemplateBlankValidator.blank_fields?(raw, context)
      raise BlankRenderFieldsError, LetterTemplateBlankValidator.blank_fields(raw, context)
    end
    raw = raw.render(context)
    if sanitize
      ActionView::Base.full_sanitizer.sanitize(raw)
    else
      raw
    end
  end

  def body_ok?
    Liquid::Template.parse(body)
  rescue Liquid::SyntaxError => e
    errors.add(:body, e.message.gsub(/^Liquid syntax error:/, '').strip)
  end

  def subject_ok?
    Liquid::Template.parse(subject)
  rescue Liquid::SyntaxError => e
    errors.add(:subject, e.message.gsub(/^Liquid syntax error:/, '').strip)
  end
end
