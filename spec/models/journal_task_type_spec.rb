require 'rails_helper'

describe JournalTaskType do
  subject(:journal_task_type) do
    FactoryGirl.build(
      :journal_task_type,
      required_permission_action: 'view',
      required_permission_applies_to: 'Foo'
    )
  end

  describe '#required_permission' do
    let!(:permission) do
      FactoryGirl.create(:permission, action: 'view', applies_to: 'Foo')
    end

    it 'returns the permission matching the required action and applies_to' do
      expect(journal_task_type.required_permission).to eq(permission)
    end

    context 'and no permission does not exist 'do
      it 'raises an exception' do
        permission.destroy
        expect do
          journal_task_type.required_permission
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'and there the required_permission_action is blank' do
      it 'returns nil' do
        journal_task_type.required_permission_action = nil
        expect(journal_task_type.required_permission).to be(nil)
      end
    end

    context 'and there the required_permission_applies_to is blank' do
      it 'returns nil' do
        journal_task_type.required_permission_action = nil
        expect(journal_task_type.required_permission).to be(nil)
      end
    end
  end
end
