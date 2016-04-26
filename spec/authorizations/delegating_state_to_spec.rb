require 'rails_helper'

describe '#delegate_state_to' do
  include AuthorizationSpecHelper

  before(:all) do
    Authorizations.reset_configuration
  end

  after do
    Authorizations.reset_configuration
  end

  let!(:user) { FactoryGirl.create(:user) }
  let!(:paper) { FactoryGirl.create(:paper) }
  let!(:task) { FactoryGirl.create(:task, paper: paper) }

  permissions do
    permission action: 'edit', applies_to: Task.name, states: Paper::EDITABLE_STATES
  end

  role :for_viewing do
    has_permission action: 'edit', applies_to: Task.name
  end

  context <<-DESC do
    Task delegates permission states to its associated paper
    and the user is assigned a task
  DESC
    before do
      assign_user user, to: task, with_role: role_for_viewing
    end

    context 'the paper is in an editable state' do
      before do
        paper.update_column(:publishing_state, Paper::EDITABLE_STATES.first)
      end

      it 'allows the user edit the task' do
        expect(user.can?(:edit, task)).to be(true)
      end
    end
    context 'the paper is in an uneditable state' do
      before do
        paper.update_column(:publishing_state, Paper::UNEDITABLE_STATES.first)
      end
      it 'does not allow the user edit the task' do
        expect(user.can?(:edit, task)).to be(false)
      end
    end
  end
end
