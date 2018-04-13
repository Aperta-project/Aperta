# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
