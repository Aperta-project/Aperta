require 'rails_helper'

describe OrcidAccountSerializer do
  subject(:serializer) do
    described_class.new(orcid_account).tap do |serializer|
      # The :current_user method is provided by the controller when responding
      # to a request as it includes the ActionController::Serialization
      # module into each serializer with a serialization_scope of
      # :current_user. We need to make #current_user available for this
      # test.
      _current_user = current_user
      serializer.send :define_singleton_method, :current_user do
        _current_user
      end
    end
  end
  let(:orcid_account) do
    FactoryGirl.build_stubbed(
      :orcid_account,
      id: 99,
      identifier: '1234',
      name: 'foobar',
      oauth_authorize_url: 'example.com/authorize',
      user_id: current_user.id
    )
  end
  let(:current_user){ FactoryGirl.build_stubbed(:user) }

  describe '#as_json' do
    let(:json) { serializer.as_json[:orcid_account] }

    it 'serializes to JSON' do
      expect(json).to match hash_including(
        id: orcid_account.id,
        identifier: orcid_account.identifier,
        name: orcid_account.name,
        oauth_authorize_url: orcid_account.oauth_authorize_url,
        profile_url: orcid_account.profile_url,
        status: orcid_account.status
      )
    end

    context 'and the OrcidAccount#user is not the #current_user' do
      before do
        orcid_account.user_id += 1
        expect(orcid_account.user_id).to_not eq current_user.id
      end

      it 'does not include #name' do
        expect(json).to_not have_key(:key)
      end

      it 'does not include #oauth_authorize_url' do
        expect(json).to_not have_key(:oauth_authorize_url)
      end

      it 'does not include #status' do
        expect(json).to_not have_key(:status)
      end
    end
  end
end
