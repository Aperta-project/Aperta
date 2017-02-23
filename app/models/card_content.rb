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

  has_many :answers

  # In the near future, we'll be seeding/migrating existing nested questions
  # for every journal in the system.  It's highly possible for multiple
  # CardContent records with a given ident to exist in the database at the same time,
  # so we'll always need to scope queries based on ident to a particular journal
  def self.for_journal(journal)
    joins(:card).where('cards.journal_id' => journal.id)
  end

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
    update_nested!(content_hashes, updated_idents)

    existing_idents = all.map(&:ident)
    for_deletion = existing_idents - updated_idents
    where(ident: for_deletion).destroy_all
  end

  def self.update_nested!(content_hashes, idents)
    content_hashes.map do |hash|
      idents.append(hash[:ident])
      child_hashes = hash.delete(:children) || []
      children = update_nested!(child_hashes, idents)

      content = CardContent.find_or_initialize_by(ident: hash[:ident])
      content.children = children
      content.update!(hash)
      content
    end
  end
end
