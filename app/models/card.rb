# Card is a container for CardContents
class Card < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :journal
  has_many :card_content, inverse_of: :card, dependent: :destroy
  validates :name, presence: true
  has_one :content_root, -> { where(parent_id: nil) }, class_name: 'CardContent'
end
