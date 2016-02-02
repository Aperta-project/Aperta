require 'rails_helper'

describe JournalTaskType do
  subject(:journal_task_type) do
    FactoryGirl.build(
      :journal_task_type,
      required_permissions: [
        { action: 'view', applies_to: 'Foo'},
        { action: 'edit', applies_to: 'Bar'}
      ]
    )
  end

  describe '#required_permissions' do
    let!(:view_permission) do
      FactoryGirl.create(:permission, action: 'view', applies_to: 'Foo')
    end
    let!(:edit_permission) do
      FactoryGirl.create(:permission, action: 'edit', applies_to: 'Bar')
    end

    it 'returns the permissions matching the required action(s) and applies_to(s)' do
      expect(journal_task_type.required_permissions).to contain_exactly(
        view_permission,
        edit_permission
      )
    end

    context 'and no permission does not exist 'do
      it 'does not include the missing permission' do
        view_permission.destroy
        expect(journal_task_type.required_permissions).to_not(
          include(view_permission)
        )
      end
    end

    context 'and there the required_permissions is blank' do
      it 'returns an empty array' do
        journal_task_type.required_permissions = nil
        expect(journal_task_type.required_permissions).to eq([])
      end
    end
  end
end
