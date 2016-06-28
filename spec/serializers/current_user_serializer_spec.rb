require 'rails_helper'

describe CurrentUserSerializer, serializer_test: true do
  include AuthorizationSpecHelper

  before do
    Authorizations::Configuration.reset
  end

  let(:user) { FactoryGirl.create(:user) }
  let(:object_for_serializer) { user }

  permission action: :view_profile, applies_to: 'User', states: ['*']

  role 'User' do
    has_permission action: 'view_profile', applies_to: 'User'
  end

  describe '#permissions' do
    it 'sideloads permissions for the current user' do
      assign_user user, to: user, with_role: role_User

      expect(deserialized_content)
        .to match(hash_including(
                    permissions: contain_exactly(
                      object: { id: user.id, type: 'User' },
                      permissions: { view_profile: { states: ['*'] } },
                      id: "user+#{user.id}")))
    end
  end
end
