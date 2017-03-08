# Card is a container for CardContents
class Card < ActiveRecord::Base
  include EventStream::Notifiable
  acts_as_paranoid

  belongs_to :journal, inverse_of: :cards
  has_many :card_versions, inverse_of: :card, dependent: :destroy
  validates :name, presence: { message: "Please give your card a name." }
  validates :name, uniqueness: {
    scope: :journal,
    message: "That card name is taken. Please give your card a new name."
  }

  # this method is used in the shim layer between nested questions
  # on the front end and card content on the backend.
  # in those cases, we don't need the proper tree of card content,
  # as the client is simply going to look up records by their ident
  # instead of traversing them.
  def latest_content_without_root
    content_for_version(:latest)
      .where.not(parent_id: nil)
  end

  # can take a version number or the symbol `:latest`
  def content_for_version(version_no)
    content_root_for_version(version_no).self_and_descendants
  end

  # can take a version number or the symbol `:latest`
  def content_root_for_version(version_no)
    to_find = if version_no == :latest
                latest_version
              else
                version_no
              end
    card_versions.find_by!(version: to_find).card_content
  end

  def self.create_new!(attrs)
    Card.transaction do
      card = Card.create!(attrs)
      root = CardContent.create!(card: card)
      CardVersion.create!(version: 1, card: card, card_content: root)
      card
    end
  end

  def self.lookup_card(owner_type)
    Card.find_by!(name: owner_type.to_s)
  end
end
