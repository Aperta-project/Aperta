# CardContent represents any piece of user-configurable content
# that will be rendered into a card.  This includes things like
# questions (radio buttons, text input, selects), static informational
# text, or widgets (developer-created chunks of functionality with
# user-configured behavior)
class CardContent < ActiveRecord::Base
  acts_as_nested_set
  acts_as_paranoid

  belongs_to :card, inverse_of: :card_content

  validates :card, presence: true
  validates :card, uniqueness:
                     { message: 'can only have a single root content.' },
                   if: ->() { parent_id.nil? }

  has_many :answers
end
