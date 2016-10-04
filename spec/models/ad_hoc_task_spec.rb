require 'rails_helper'

describe AdHocTask do
  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults does not update title'
    it_behaves_like '<Task class>.restore_defaults does not update old_role'
  end
end
