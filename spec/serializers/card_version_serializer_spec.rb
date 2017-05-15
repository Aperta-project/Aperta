require 'rails_helper'

describe do
  subject(:serializer) { CardVersionSerializer.new(card_version) }
  let(:card_version) { FactoryGirl.create(:card_version) }

  describe '#as_json' do
    let(:json) { serializer.as_json }

    it 'serializes attributes' do
      aggregate_failures('json') do
        expect(json[:card_version]).to include(id: card_version.id)
        expect(json[:card_contents]).to_not be_empty
      end
    end
  end
end
