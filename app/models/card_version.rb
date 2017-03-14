# CardVersion joins a Card to the different versions of its
# CardContent.  The card_versions table itself can also serve
# as a container for information we need to version that isn't
# card content
class CardVersion < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :card
  has_many :card_contents

  validates :card, presence: true
  validates :card_contents, presence: true
  has_one :content_root, -> { where(parent: nil) },
    class_name: 'CardContent'

  validates :version, uniqueness: {
    scope: :card_id,
    message: "Card version numbers are unique for a given card"
  }
end
