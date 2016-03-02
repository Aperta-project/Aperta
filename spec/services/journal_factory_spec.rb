require 'rails_helper'

describe JournalFactory do
  describe '.create' do
    include AuthorizationSpecHelper

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
      before(:all) do
        clear_roles_and_permissions
        JournalFactory.create(name: 'Genetics Journal')
      end

      after(:all) do
        clear_roles_and_permissions
      end

      let!(:journal) { Journal.first! }
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

        describe 'permissions on tasks' do
          let(:accessible_task_klasses) do
            ::Task.descendants - inaccessible_task_klasses
          end
          let(:inaccessible_task_klasses) do
            [TahiStandardTasks::ProductionMetadataTask]
          end

          it 'can :view and :edit all Tasks except ProductionMetadataTask' do
            accessible_task_klasses.each do |klass|
              expect(journal.creator_role.permissions).to include(
                Permission.find_by(action: :view, applies_to: klass.name),
                Permission.find_by(action: :edit, applies_to: klass.name)
              )
            end

            inaccessible_task_klasses.each do |klass|
              expect(journal.creator_role.permissions).to_not include(
                Permission.find_by(action: :view, applies_to: klass.name),
                Permission.find_by(action: :edit, applies_to: klass.name)
              )
            end
          end

          it 'can view/add/remove participants on all Tasks except ProductionMetadataTask' do
            accessible_task_klasses.each do |klass|
              expect(journal.creator_role.permissions).to include(
                Permission.find_by(action: :view_participants, applies_to: klass.name),
                Permission.find_by(action: :add_participants, applies_to: klass.name),
                Permission.find_by(action: :remove_participants, applies_to: klass.name)
              )
            end

            inaccessible_task_klasses.each do |klass|
              expect(journal.creator_role.permissions).to_not include(
                Permission.find_by(action: :view_participants, applies_to: klass.name),
                Permission.find_by(action: :add_participants, applies_to: klass.name),
                Permission.find_by(action: :remove_participants, applies_to: klass.name)
              )
            end
          end

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

        it 'is able to see most metadata_tasks like the Data Availability Task' do
          expect(Task.descendants.select { |klass| klass <=> MetadataTask }
                                 .select { |klass| klass.name == 'TahiStandardTasks::DataAvailabilityTask' }
                ).to be_present
          expect(journal.collaborator_role.permissions).to include(
            Permission.where(action: 'view', applies_to: 'TahiStandardTasks::DataAvailabilityTask').first
          )
        end

        it 'is able to see most submission_tasks like the ReviewerRecommendationsTask' do
          expect(Task.descendants.select { |klass| klass <=> SubmissionTask }
                                 .select { |klass| klass.name == 'TahiStandardTasks::ReviewerRecommendationsTask' }
                ).to be_present
          expect(journal.collaborator_role.permissions).to include(
            Permission.where(action: 'view', applies_to: 'TahiStandardTasks::ReviewerRecommendationsTask').first
          )
        end

        it 'but should not be able to see the Billing Task' do
          expect(journal.collaborator_role.permissions).not_to include(
            Permission.where(action: 'view', applies_to: 'PlosBilling::BillingTask').first
          )
        end
      end

      context 'Cover Editor role' do
        context 'has Paper permission to' do
          let(:permissions) { Permission.joins(:states).where(applies_to: 'Paper', permission_states: { id: PermissionState.wildcard }) }

          it ':view' do
            expect(journal.cover_editor_role.permissions).to include(
              permissions.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(journal.cover_editor_role.permissions).to include(
              permissions.find_by(action: 'edit')
            )
          end

          it ':manage_workflow' do
            expect(journal.cover_editor_role.permissions).to include(
              permissions.find_by(action: 'manage_workflow')
            )
          end

          it ':manage_collaborators' do
            expect(journal.cover_editor_role.permissions).to include(
              permissions.find_by(action: 'manage_collaborators')
            )
          end

          it ':start_discussion' do
            expect(journal.cover_editor_role.permissions).to include(
              permissions.find_by(action: 'start_discussion')
            )
          end
        end

        context 'has Task permission to' do
          let(:permissions) { Permission.joins(:states).where(applies_to: 'Task', permission_states: { id: PermissionState.wildcard }) }

          it ':view' do
            expect(journal.cover_editor_role.permissions).to include(
              permissions.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(journal.cover_editor_role.permissions).to include(
              permissions.find_by(action: 'edit')
            )
          end

          it ':add_participants' do
            expect(journal.cover_editor_role.permissions).to include(
              permissions.find_by(action: 'add_participants')
            )
          end

          it ':remove_participants' do
            expect(journal.cover_editor_role.permissions).to include(
              permissions.find_by(action: 'remove_participants')
            )
          end
        end

        context 'has DiscussionTopic permission to' do
          let(:permissions) { Permission.joins(:states).where(applies_to: 'DiscussionTopic', permission_states: { id: PermissionState.wildcard }) }

          it ':view' do
            expect(journal.cover_editor_role.permissions).to include(
              permissions.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(journal.cover_editor_role.permissions).to include(
              permissions.find_by(action: 'edit')
            )
          end

          it ':manage_participant' do
            expect(journal.cover_editor_role.permissions).to include(
              permissions.find_by(action: 'manage_participant')
            )
          end

          it ':reply' do
            expect(journal.cover_editor_role.permissions).to include(
              permissions.find_by(action: 'reply')
            )
          end
        end
      end

      context 'Academic Editor' do
        it 'is able to see most metadata_tasks like the Data Availability Task' do
          expect(Task.descendants.select { |klass| klass <=> MetadataTask }
                                 .select { |klass| klass.name == 'TahiStandardTasks::DataAvailabilityTask' }
                ).to be_present
          expect(journal.academic_editor_role.permissions).to include(
            Permission.where(action: 'view', applies_to: 'TahiStandardTasks::DataAvailabilityTask').first
          )
        end

        it 'but should not be able to see the Billing Task' do
          expect(journal.academic_editor_role.permissions).not_to include(
            Permission.where(action: 'view', applies_to: 'PlosBilling::BillingTask').first
          )
        end

        it 'is able to view and edit the ReviewerRecommendationsTask' do
          expect(journal.academic_editor_role.permissions).to include(
            Permission.where(action: 'view', applies_to: 'TahiStandardTasks::ReviewerRecommendationsTask').first
          )
          expect(journal.academic_editor_role.permissions).to include(
            Permission.where(action: 'edit', applies_to: 'TahiStandardTasks::ReviewerRecommendationsTask').first
          )
        end
      end

      context 'Handling Editor' do
        it 'has :start_discussion permissions on Paper' do
          permissions = Permission.joins(:states).where(applies_to: 'Paper', permission_states: { id: PermissionState.wildcard })

          expect(journal.handling_editor_role.permissions).to include(
            permissions.find_by(action: 'start_discussion')
          )
        end

        context 'has DiscussionTopic permission to' do
          let(:permissions) { Permission.joins(:states).where(applies_to: 'DiscussionTopic', permission_states: { id: PermissionState.wildcard }) }

          it ':view' do
            expect(journal.handling_editor_role.permissions).to include(
              permissions.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(journal.handling_editor_role.permissions).to include(
              permissions.find_by(action: 'edit')
            )
          end

          it ':manage_participant' do
            expect(journal.handling_editor_role.permissions).to include(
              permissions.find_by(action: 'manage_participant')
            )
          end

          it ':reply' do
            expect(journal.handling_editor_role.permissions).to include(
              permissions.find_by(action: 'reply')
            )
          end
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

      context 'Production Staff' do
        it 'has :start_discussion permissions on Paper' do
          permissions = Permission.joins(:states).where(applies_to: 'Paper', permission_states: { id: PermissionState.wildcard })

          expect(journal.production_staff_role.permissions).to include(
            permissions.find_by(action: 'start_discussion')
          )
        end

        context 'has DiscussionTopic permission to' do
          let(:permissions) { Permission.joins(:states).where(applies_to: 'DiscussionTopic', permission_states: { id: PermissionState.wildcard }) }

          it ':view' do
            expect(journal.production_staff_role.permissions).to include(
              permissions.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(journal.production_staff_role.permissions).to include(
              permissions.find_by(action: 'edit')
            )
          end

          it ':manage_participant' do
            expect(journal.production_staff_role.permissions).to include(
              permissions.find_by(action: 'manage_participant')
            )
          end

          it ':reply' do
            expect(journal.production_staff_role.permissions).to include(
              permissions.find_by(action: 'reply')
            )
          end
        end
      end

      context 'Publishing Services' do
        it 'has :start_discussion permissions on Paper' do
          permissions = Permission.joins(:states).where(applies_to: 'Paper', permission_states: { id: PermissionState.wildcard })

          expect(journal.publishing_services_role.permissions).to include(
            permissions.find_by(action: 'start_discussion')
          )
        end

        context 'has DiscussionTopic permission to' do
          let(:permissions) { Permission.joins(:states).where(applies_to: 'DiscussionTopic', permission_states: { id: PermissionState.wildcard }) }

          it ':view' do
            expect(journal.publishing_services_role.permissions).to include(
              permissions.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(journal.publishing_services_role.permissions).to include(
              permissions.find_by(action: 'edit')
            )
          end

          it ':manage_participant' do
            expect(journal.publishing_services_role.permissions).to include(
              permissions.find_by(action: 'manage_participant')
            )
          end

          it ':reply' do
            expect(journal.publishing_services_role.permissions).to include(
              permissions.find_by(action: 'reply')
            )
          end
        end
      end

      context 'Discussion Participant' do
        context 'has DiscussionTopic permission to' do
          let(:permissions) { Permission.joins(:states).where(applies_to: 'DiscussionTopic', permission_states: { id: PermissionState.wildcard }) }

          it ':view' do
            expect(journal.discussion_participant_role.permissions).to include(
              permissions.find_by(action: 'view')
            )
          end

          it ':reply' do
            expect(journal.discussion_participant_role.permissions).to include(
              permissions.find_by(action: 'reply')
            )
          end
        end
      end

      context 'Staff Admin' do
        it 'has :start_discussion permissions on Paper' do
          permissions = Permission.joins(:states).where(applies_to: 'Paper', permission_states: { id: PermissionState.wildcard })

          expect(journal.staff_admin_role.permissions).to include(
            permissions.find_by(action: 'start_discussion')
          )
        end

        it 'is able to see Tasks in general' do
          expect(journal.staff_admin_role.permissions).to include(
            Permission.where(action: 'view', applies_to: 'Task').first
          )
        end

        it 'but should not be able to see the Billing Task' do
          expect(journal.staff_admin_role.permissions).to include(
            Permission.where(action: 'view', applies_to: 'PlosBilling::BillingTask').first
          )
        end

        context 'has DiscussionTopic permission to' do
          let(:permissions) { Permission.joins(:states).where(applies_to: 'DiscussionTopic', permission_states: { id: PermissionState.wildcard }) }

          it ':view' do
            expect(journal.staff_admin_role.permissions).to include(
              permissions.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(journal.staff_admin_role.permissions).to include(
              permissions.find_by(action: 'edit')
            )
          end

          it ':manage_participant' do
            expect(journal.staff_admin_role.permissions).to include(
              permissions.find_by(action: 'manage_participant')
            )
          end

          it ':reply' do
            expect(journal.staff_admin_role.permissions).to include(
              permissions.find_by(action: 'reply')
            )
          end
        end
      end
    end
  end
end
