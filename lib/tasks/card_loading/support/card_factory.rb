# This class creates new valid Cards in the system by using the
# CardConfiguration classes to determine the correct Card attributes to set.
#
class CardFactory
  attr_accessor :journal

  def initialize(journal: nil)
    @journal = journal
  end

  def create(configuration_klasses)
    Array(configuration_klasses).each do |klass|
      create_from_configuration_klass(klass)
    end
  end

  def create_from_configuration_klass(configuration_klass)
    create_from_content(name: configuration_klass.name, new_content: configuration_klass.content)
  end

  def create_from_content(name: nil, new_content: [])
    card = card_to_load(name: name, journal: journal)
    card_version = card.latest_card_version
    content_root = card_version.content_root

    update_card_content(
      CardContent.where(card_version: card_version).where.not(ident: nil),
      new_content,
      content_root,
      card_version
    )

    card.publish! if card.draft?
    card.lock! if journal.blank? && !card.locked?
    card.reload
  end

  # This method runs on a scope and takes and a list of nested property
  # hashes. Each hash represents a single piece of card content, and must
  # have at least an `ident` field.
  # Any content with hashes but not in scope will be created.
  def update_card_content(existing_content, content_hashes, content_root, card_version)
    updated_idents = update_nested!(content_hashes, content_root.id, card_version)

    existing_idents = existing_content.map(&:ident)
    for_deletion = existing_idents - updated_idents
    raise "You forgot some questions: #{for_deletion}" \
      unless for_deletion.empty?
  end

  def update_nested!(content_hashes, parent_id, card_version)
    updated_idents = []
    content_hashes.each do |hash|
      updated_idents.append(hash[:ident])
      # we'll be using the hash as an argument to update the ActiveRecord model, so it can't
      # have the :children key on it (AR would expect an array of models, not hashes).
      child_hashes = hash.delete(:children) || []
      # this method will likely need to change once idents are no longer unique
      content = CardContent.find_or_initialize_by(card_version: card_version, ident: hash[:ident])
      content.parent_id = parent_id
      content.update!(hash)
      updated_idents.concat update_nested!(child_hashes, content.id, card_version)
    end
    updated_idents
  end

  private

  def card_to_load(name:, journal:)
    existing_card = Card.find_by(name: name, journal: journal)
    if existing_card && existing_card.latest_version > 1
      raise ArgumentError,
            <<-DOC
              Existing Cards with a latest version > 1
              (like #{existing_card.name}, v. #{existing_card.latest_version})
              cannot be reloaded or modified via the CardFactory
            DOC
    end

    # the line below should hypothetically only happen once per environment, but it's more straightforward
    # to include it here than to make a separate data migration
    existing_card || Card.create_published!(name: name, journal: journal)
  end
end
