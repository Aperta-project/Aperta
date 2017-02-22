# Card is a container for CardContents
class Card < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :journal
  has_many :card_content, inverse_of: :card, dependent: :destroy
  validates :name, presence: { message: "Please give your card a name." }
  validates :journal, presence: true
  validates :name, uniqueness: {
    scope: :journal,
    message: "That card name is taken. Please give your card a new name."
  }

  def content_root
    card_content.roots.first
  end
end
