# This is meant to hold different types of letter templates for decisions
# and any other use cases where a letter template with variable replacement
# would be useful.
class LetterTemplate < ActiveRecord::Base
  belongs_to :journal

  validates :letter, presence: true
  validates :subject, presence: true

  def render_attr(attr, options = {})
    Liquid::Template.parse(attr).render(options)
  end

  def render(options = {})
    tap do |my|
      my.subject = render_attr(subject, options)
      my.to = render_attr(to, options)
      my.letter = render_attr(letter, options)
    end
  end
end
