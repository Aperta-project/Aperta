# CardVersion joins a Card to the different versions of its
# CardContent.  The card_versions table itself can also serve
# as a container for information we need to version that isn't
# card content
class CardVersion < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :card
  belongs_to :card_content

  validates :card, presence: true
  validates :card_content, presence: true
end
