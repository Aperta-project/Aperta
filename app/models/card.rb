# Card is a container for CardContents
class Card < ActiveRecord::Base
  acts_as_paranoid

  has_many :card_content, inverse_of: :card, dependent: :destroy
  validates :name, presence: true

  def content_root
    card_content.roots.first
  end
end
