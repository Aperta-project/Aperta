require 'rails_helper'

describe JournalFactory do
  describe '.create' do
    include AuthorizationSpecHelper

    before do
      clear_roles_and_permissions
    end

    it 'creates a new journal' do
      expect do
        JournalFactory.create(name: 'Journal of the Stars')
      end.to change(Journal, :count).by(1)
    end

    it 'uses the given params to create the new journal' do
      journal = JournalFactory.create(name: 'Journal of the Stars')
      expect(journal.name).to eq('Journal of the Stars')
    end

    context 'creating the default roles and permission for the journal' do
      let(:journal) { JournalFactory.create(name: 'Genetics Journal') }
      let(:journal_author_role) do
        journal.roles.where(name: Role::AUTHOR_ROLE).first
      end

      let(:view_paper_permission) do
        Permission.where(action: 'view', applies_to: 'Paper').first!
      end

      it 'gives the journal its own Creator role' do
        expect(journal_author_role).to be
      end

      context 'Author role' do
        it 'gets the :view Paper permission with no state requirements' do
          expect(journal_author_role.permissions).to include(
            view_paper_permission
          )
          expect(view_paper_permission.states).to contain_exactly(
            PermissionState.wildcard
          )
        end
      end
    end
  end
end
