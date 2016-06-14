require 'rails_helper'

describe Role do
  describe '#user_role' do
    it 'caches the role object' do
      expect(Role.user_role).not_to be(nil)
      old_user_role = Role.user_role
      expect(Role.user_role).to be(old_user_role)
    end
  end
end
