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
      let(:view_paper_permission) do
        Permission.where(action: 'view', applies_to: 'Paper').first
      end

      it 'gives the journal its own Creator role' do
        expect(journal.roles.creator).to be
      end

      context 'Creator role' do
        it 'gets the :view Paper permission with no state requirements' do
          expect(journal.roles.collaborator.permissions).to include(
            view_paper_permission
          )
          expect(view_paper_permission.states).to contain_exactly(
            PermissionState.wildcard
          )
        end
      end

      it 'gives the journal its own Collaborator role' do
        expect(journal.roles.collaborator).to be
      end

      context 'Collaborator role' do
        it 'gets the :view Paper permission with no state requirements' do
          expect(journal.roles.collaborator.permissions).to include(
            Permission.where(action: 'view', applies_to: 'Paper').first
          )
          expect(view_paper_permission.states).to contain_exactly(
            PermissionState.wildcard
          )
        end
      end

      context 'Internal Editor' do
        context 'has DisscussionTopic permission to' do
          let(:permissions) { Permission.joins(:states).where(applies_to: 'DiscussionTopic', permission_states: { id: PermissionState.wildcard }) }

          it ':view' do
            expect(journal.roles.internal_editor.permissions).to include(
              permissions.find_by(action: 'view')
            )
          end

          it ':create' do
            expect(journal.roles.internal_editor.permissions).to include(
              permissions.find_by(action: 'create')
            )
          end

          it ':edit' do
            expect(journal.roles.internal_editor.permissions).to include(
              permissions.find_by(action: 'edit')
            )
          end

          it ':add_participant' do
            expect(journal.roles.internal_editor.permissions).to include(
              permissions.find_by(action: 'add_participant')
            )
          end

          it ':reply' do
            expect(journal.roles.internal_editor.permissions).to include(
              permissions.find_by(action: 'reply')
            )
          end
        end
      end

      context 'Publishing Services and Production Staff' do
        context 'has DisscussionTopic permission to' do
          let(:permissions) { Permission.joins(:states).where(applies_to: 'DiscussionTopic', permission_states: { id: PermissionState.wildcard }) }

          it ':view' do
            expect(journal.roles.internal_editor.permissions).to include(
              permissions.find_by(action: 'view')
            )
          end

          it ':create' do
            expect(journal.roles.internal_editor.permissions).to include(
              permissions.find_by(action: 'create')
            )
          end

          it ':edit' do
            expect(journal.roles.internal_editor.permissions).to include(
              permissions.find_by(action: 'edit')
            )
          end

          it ':add_participant' do
            expect(journal.roles.internal_editor.permissions).to include(
              permissions.find_by(action: 'add_participant')
            )
          end

          it ':reply' do
            expect(journal.roles.internal_editor.permissions).to include(
              permissions.find_by(action: 'reply')
            )
          end
        end
      end

      context 'Discussion Particiapnt' do
        context 'has DisscussionTopic permission to' do
          let(:permissions) { Permission.joins(:states).where(applies_to: 'DiscussionTopic', permission_states: { id: PermissionState.wildcard }) }

          it ':view' do
            expect(journal.roles.internal_editor.permissions).to include(
              permissions.find_by(action: 'view')
            )
          end

          it ':reply' do
            expect(journal.roles.internal_editor.permissions).to include(
              permissions.find_by(action: 'reply')
            )
          end
        end
      end
    end
  end
end
