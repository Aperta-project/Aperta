require 'rails_helper'

describe CurrentUserSerializer do
  include AuthorizationSpecHelper

  subject(:serializer){ described_class.new(user) }
  let(:user) { FactoryGirl.create(:user) }
  permission action: :view_profile, applies_to: 'User', states: ['*']
  role 'User' do
    has_permission action: 'view_profile', applies_to: 'User'
  end

  describe '#permissions' do
    it 'sideloads permissions for the current user' do
      assign_user user, to: user, with_role: role_User

      expect(serializer.as_json[:permissions]).to eq([
        {
          object: { id: user.id, type: 'User' },
          permissions: { view_profile: { states: ['*'] } },
          id: "user+#{user.id}"
        }
      ].as_json)
    end
  end
end
