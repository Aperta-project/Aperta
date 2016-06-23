require 'rails_helper'

describe Role do
  let(:user_role) { Role.find_or_create_by!(name: Role::USER_ROLE, journal: nil) }

  describe '#user_role' do
    it 'returns the role object' do
      expect(Role.user_role).to eq(user_role)
    end
  end
end
