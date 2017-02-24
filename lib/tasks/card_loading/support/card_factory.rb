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
    card = Card.find_or_create_by!(name: configuration_klass.name, journal: journal)
    content_root = CardContent.find_or_create_by!(card: card, ident: nil, parent: nil)
    configuration_klass.content.each do |c|
      c[:parent] = content_root
      c[:card] = card
    end

    CardContent.where(card: card).where.not(ident: nil)
               .update_all_exactly!(configuration_klass.content)
  end
end
