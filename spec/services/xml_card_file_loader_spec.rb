require 'rails_helper'

describe CustomCard::FileLoader do
  before(:all) do
    Journal.delete_all
  end

  after(:all) do
    Permission.delete_all
    Role.delete_all
    Journal.delete_all
    CardContentValidation.delete_all
    EntityAttribute.delete_all
    CardContent.delete_all
    CardVersion.delete_all
    TaskTemplate.delete_all
    Card.delete_all
    CardTaskType.delete_all
    LetterTemplate.delete_all
  end

  context 'card loading' do
    let(:journal) do
      JournalFactory.create(
        name: 'Genetics Journal',
        doi_journal_prefix: 'journal.genetics',
        doi_publisher_prefix: 'genetics',
        last_doi_issued: '100001'
      )
    end

    before { CustomCard::FileLoader.load(journal) }
    let(:default_permissions) { CustomCard::DefaultCardPermissions.new(journal) }

    it 'loads default system cards with the expected roles and permissions' do
      default_cards = CustomCard::FileLoader.names.sort
      expect(journal.cards.count).to eq(default_cards.count)

      cards = journal.cards.order(:name).where(name: default_cards.map(&:titleize)).load
      expect(cards.count).to eq(default_cards.count)

      cards.zip(default_cards).each do |card, file_name|
        default_permissions.match(file_name, card.card_permissions) do |default_roles, card_roles|
          expect(default_roles).to match_array(card_roles), "Mismatched permissions on #{card.name} from #{file_name}"
        end
      end
    end
  end
end
