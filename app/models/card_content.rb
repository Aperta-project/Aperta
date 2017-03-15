# CardContent represents any piece of user-configurable content
# that will be rendered into a card.  This includes things like
# questions (radio buttons, text input, selects), static informational
# text, or widgets (developer-created chunks of functionality with
# user-configured behavior)
class CardContent < ActiveRecord::Base
  acts_as_nested_set
  acts_as_paranoid

  belongs_to :card_version
  has_one :card, through: :card_version

  validates :card_version, presence: true
  validates :parent_id,
            uniqueness: {
              scope: :card_version,
              message: "Card versions can only have one root node."
            },
            if: -> { parent_id.nil? }

  has_many :answers

  validates :ident,
            uniqueness: {
              message: "CardContent idents must be unique"
            },
            if: -> { ident.present? }

  # Note that we essentially copied this method over from nested question
  def self.update_all_exactly!(content_hashes)
    # This method runs on a scope and takes and a list of nested property
    # hashes. Each hash represents a single piece of card content, and must
    # have at least an `ident` field.
    #
    # ANY CONTENT IN SCOPE WITHOUT HASHES IN THIS LIST WILL BE DESTROYED.
    #
    # Any content with hashes but not in scope will be created.

    updated_idents = []

    # Refresh the living, welcome the newly born
    update_nested!(content_hashes, nil, updated_idents)

    existing_idents = all.map(&:ident)
    for_deletion = existing_idents - updated_idents
    raise "You forgot some questions: #{for_deletion}" \
      unless for_deletion.empty?
  end

  def self.update_nested!(content_hashes, parent_id, idents)
    content_hashes.map do |hash|
      idents.append(hash[:ident])
      child_hashes = hash.delete(:children) || []
      content = CardContent.find_or_initialize_by(ident: hash[:ident])
      content.parent_id = parent_id
      content.update!(hash)
      update_nested!(child_hashes, content.id, idents)
      content
    end
  end
end
