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
  validate :cc_ok?
  validate :bcc_ok?
  before_validation :canonicalize_email_addresses

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

  def cc_ok?
    return unless cc
    cc.split(/,/).each do |email|
      errors.add(:cc, "\"#{email}\" is an invalid email address") unless email.match(Devise.email_regexp)
    end
  end

  def bcc_ok?
    return unless bcc
    bcc.split(/,/).each do |email|
      errors.add(:bcc, "\"#{email}\" is an invalid email address") unless email.match(Devise.email_regexp)
    end
  end

  def canonicalize_email_addresses
    self.cc = canonicalize(cc) if cc
    self.bcc = canonicalize(bcc) if bcc
  end

  # This accepts a variety of user-inputted email address formats, handles multiple addresses safely, and ends
  # with a comma delimited list of simple addresses.
  def canonicalize(address_line)
    address_line.gsub(/"[^"]+"/, '')           # Git rid of quoted part of "Joe Smith, the third" <joe@gmail.com> addresses
      .split(/[,;]+/)                          # Account for multiple addresses delimited by either comma or semicolon
      .map(&:strip)                            # Git rid of surrounding whitespace
      .map { |a| a.gsub(/.*<(.+)>$/, '\1') }   # Strip angle brackets and any leading friendly names that weren't quoted
      .join(',')                               # ...and join them back together with the Tahi standard email separator
  end
end
