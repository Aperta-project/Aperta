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

  private

  def create_from_configuration_klass(configuration_klass)
    existing_card = Card.find_by(name: configuration_klass.name, journal: journal, latest_version: 1)
    # the line below should hypothetically only happen once per environment, but it's more straightforward
    # to include it here than to make a separate data migration
    existing_card.publish! if existing_card && existing_card.draft?
    card = existing_card || Card.create_published!(name: configuration_klass.name,
                                                   journal: journal)
    card_version = card.latest_published_card_version
    content_root = card_version.content_root
    new_content = configuration_klass.content
    new_content.each do |c|
      c[:parent] = content_root
      c[:card_version] = card_version
    end
    CardContent.where(card_version: card_version).where.not(ident: nil)
               .update_all_exactly!(new_content)
  end
end
