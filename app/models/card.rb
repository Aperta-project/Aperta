# Card is a container for CardContents
class Card < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :journal
  has_many :card_content, inverse_of: :card, dependent: :destroy
  validates :name, presence: true
  validates :journal, presence: true

  def content_root
    card_content.roots.first
  end
end
