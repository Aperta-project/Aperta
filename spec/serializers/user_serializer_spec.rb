require 'rails_helper'

describe UserSerializer, serializer_test: true do
  subject(:serializer) { described_class.new(user) }
  let(:user) do
    FactoryGirl.build_stubbed(
      :user,
      id: 99,
      affiliations: [affiliation],
      first_name: "Kyoto",
      last_name: "Rainstorm",
      orcid_account: orcid_account,
      username: "kyoto.rainstorm"
    )
  end
  let(:affiliation) { FactoryGirl.build_stubbed(:affiliation) }
  let(:orcid_account) { FactoryGirl.build_stubbed(:orcid_account) }

  describe '#as_json' do
    around do |example|
      ClimateControl.modify(ORCID_CONNECT_ENABLED: 'true') do
        example.run
      end
    end
    let(:json) { serializer.as_json[:user] }

    it 'serializes to JSON' do
      expect(json).to match hash_including(
        id: user.id,
        affiliation_ids: [affiliation.id],
        avatar_url: user.avatar_url,
        first_name: user.first_name,
        full_name: user.full_name,
        last_name: user.last_name,
        orcid_account_id: orcid_account.id,
        username: user.username
      )
    end

    context 'and ORCID_CONNECT_ENABLED is false' do
      around do |example|
        ClimateControl.modify(ORCID_CONNECT_ENABLED: 'false') do
          example.run
        end
      end

      it 'does not include #orcid_account_id' do
        expect(json).to_not have_key(:orcid_account_id)
      end
    end
  end
end
