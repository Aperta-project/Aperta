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
        expect(journal.creator_role).to be
      end

      context 'Creator role' do
        it 'gets the :view Paper permission with no state requirements' do
          expect(journal.collaborator_role.permissions).to include(
            view_paper_permission
          )
          expect(view_paper_permission.states).to contain_exactly(
            PermissionState.wildcard
          )
        end
      end

      it 'gives the journal its own Collaborator role' do
        expect(journal.collaborator_role).to be
      end

      context 'Collaborator role' do
        it 'gets the :view Paper permission with no state requirements' do
          expect(journal.collaborator_role.permissions).to include(
            Permission.where(action: 'view', applies_to: 'Paper').first
          )
          expect(view_paper_permission.states).to contain_exactly(
            PermissionState.wildcard
          )
        end
      end

      context 'Internal Editor' do
        it 'has :start_discussion permissions on Paper' do
          permissions = Permission.joins(:states).where(applies_to: 'Paper', permission_states: { id: PermissionState.wildcard })

          expect(journal.internal_editor_role.permissions).to include(
            permissions.find_by(action: 'start_discussion')
          )
        end

        context 'has DiscussionTopic permission to' do
          let(:permissions) { Permission.joins(:states).where(applies_to: 'DiscussionTopic', permission_states: { id: PermissionState.wildcard }) }

          it ':view' do
            expect(journal.internal_editor_role.permissions).to include(
              permissions.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(journal.internal_editor_role.permissions).to include(
              permissions.find_by(action: 'edit')
            )
          end

          it ':manage_participant' do
            expect(journal.internal_editor_role.permissions).to include(
              permissions.find_by(action: 'manage_participant')
            )
          end

          it ':reply' do
            expect(journal.internal_editor_role.permissions).to include(
              permissions.find_by(action: 'reply')
            )
          end
        end
      end

      context 'Publishing Services and Production Staff' do
        it 'has :start_discussion permissions on Paper' do
          permissions = Permission.joins(:states).where(applies_to: 'Paper', permission_states: { id: PermissionState.wildcard })

          expect(journal.internal_editor_role.permissions).to include(
            permissions.find_by(action: 'start_discussion')
          )
        end

        context 'has DiscussionTopic permission to' do
          let(:permissions) { Permission.joins(:states).where(applies_to: 'DiscussionTopic', permission_states: { id: PermissionState.wildcard }) }

          it ':view' do
            expect(journal.internal_editor_role.permissions).to include(
              permissions.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(journal.internal_editor_role.permissions).to include(
              permissions.find_by(action: 'edit')
            )
          end

          it ':manage_participant' do
            expect(journal.internal_editor_role.permissions).to include(
              permissions.find_by(action: 'manage_participant')
            )
          end

          it ':reply' do
            expect(journal.internal_editor_role.permissions).to include(
              permissions.find_by(action: 'reply')
            )
          end
        end
      end

      context 'Discussion Participant' do
        context 'has DiscussionTopic permission to' do
          let(:permissions) { Permission.joins(:states).where(applies_to: 'DiscussionTopic', permission_states: { id: PermissionState.wildcard }) }

          it ':view' do
            expect(journal.internal_editor_role.permissions).to include(
              permissions.find_by(action: 'view')
            )
          end

          it ':reply' do
            expect(journal.internal_editor_role.permissions).to include(
              permissions.find_by(action: 'reply')
            )
          end
        end
      end
    end
  end
end
