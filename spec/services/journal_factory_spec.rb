require 'rails_helper'

describe JournalFactory do
  describe '.create' do
    include AuthorizationSpecHelper

    let(:permissions_on_journal) do
      Permission.joins(:states).where(
        applies_to: 'Journal',
        permission_states: { id: PermissionState.wildcard }
      )
    end
    let(:permissions_on_paper) do
      Permission.joins(:states).where(
        applies_to: 'Paper',
        permission_states: { id: PermissionState.wildcard }
      )
    end
    let(:permissions_on_paper_with_editable_paper_states) do
      Permission.joins(:states).where(
        applies_to: 'Paper',
        permission_states: { name: Paper::EDITABLE_STATES }
      )
    end
    let(:permissions_on_paper_with_submitted_state) do
      Permission.joins(:states).where(
        applies_to: 'Paper',
        permission_states: { name: 'submitted' }
      )
    end
    let(:permissions_on_paper_with_withdrawn_state) do
      Permission.joins(:states).where(
        applies_to: 'Paper',
        permission_states: { name: 'withdrawn' }
      )
    end
    let(:permissions_on_task) do
      Permission.joins(:states).where(
        applies_to: 'Task',
        permission_states: { id: PermissionState.wildcard }
      )
    end
    let(:permissions_with_editable_paper_states) do
      Permission.joins(:states).where(
        permission_states: { name: Paper::EDITABLE_STATES }
      )
    end
    let(:permissions_on_discussion_topic) do
      Permission.joins(:states).where(
        applies_to: 'DiscussionTopic',
        permission_states: { id: PermissionState.wildcard }
      )
    end

    it 'creates a new journal with the given params' do
      expect do
        journal = JournalFactory.create(name: 'Journal of the Stars')
        expect(journal.name).to eq('Journal of the Stars')
      end.to change(Journal, :count).by(1)
    end

    context 'creating the default roles and permission for the journal' do
      before(:all) do
        clear_roles_and_permissions
        @journal = JournalFactory.create(name: 'Genetics Journal')
      end

      after(:all) do
        clear_roles_and_permissions
        @journal.destroy!
      end

      let!(:journal) { @journal }
      let(:view_paper_permission) do
        Permission.where(action: 'view', applies_to: 'Paper').first
      end

      it 'gives the journal its own Creator role' do
        expect(journal.creator_role).to be
      end

      context 'Creator role' do
        let(:permissions) { journal.creator_role.permissions }

        context 'has Paper permission to' do
          it ':view' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'edit')
            )
          end

          it ':manage_collaborators' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'manage_collaborators')
            )
          end

          it ':edit_authors' do
            expect(permissions).to include(
              permissions_on_paper_with_editable_paper_states
                .find_by(action: 'edit_authors')
            )
          end

          it ':submit' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'submit')
            )
          end

          it ':withdraw' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'withdraw')
            )
          end
        end

        describe 'permissions on tasks' do
          let(:accessible_task_klasses) do
            ::Task.submission_task_types + [PlosBioTechCheck::ChangesForAuthorTask]
          end
          let(:all_inaccessible_task_klasses) do
            ::Task.descendants - accessible_task_klasses
          end

          it 'can :view and :edit all Tasks except ProductionMetadataTask' do
            accessible_task_klasses.each do |klass|
              expect(permissions).to include(
                Permission.find_by(action: :view, applies_to: klass.name),
                Permission.joins(:states).where(
                  action: 'edit',
                  applies_to: klass.name,
                  permission_states: { name: Paper::EDITABLE_STATES }).first
              )
            end

            all_inaccessible_task_klasses.each do |klass|
              expect(permissions).to_not include(
                Permission.find_by(action: :view, applies_to: klass.name),
                Permission.joins(:states).where(
                  action: 'edit',
                  applies_to: klass.name,
                  permission_states: { name: Paper::EDITABLE_STATES }).first
              )
            end
          end

          it 'can view/add/remove participants on all Tasks except ProductionMetadataTask' do
            accessible_task_klasses.each do |klass|
              expect(permissions).to include(
                Permission.find_by(action: :view_participants, applies_to: klass.name),
                Permission.find_by(action: :manage_participant, applies_to: klass.name)
              )
            end

            all_inaccessible_task_klasses.each do |klass|
              expect(permissions).to_not include(
                Permission.find_by(action: :view_participants, applies_to: klass.name),
                Permission.find_by(action: :manage_participant, applies_to: klass.name)
              )
            end
          end
        end
      end

      it 'gives the journal its own Collaborator role' do
        expect(journal.collaborator_role).to be
      end

      context 'Collaborator role' do
        let(:permissions) { journal.collaborator_role.permissions }

        context 'has Paper permission to' do
          it ':view' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'view')
            )
          end

          it ':manage_collaborators' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'manage_collaborators')
            )
          end

          it ':submit' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'submit')
            )
          end
        end

        describe 'permissions on tasks' do
          let(:accessible_task_klasses) do
            accessible_for_role = ::Task.descendants.select do |klass|
              klass <=> SubmissionTask
            end
            accessible_for_role - inaccessible_task_klasses
          end
          let(:inaccessible_task_klasses) do
            [PlosBilling::BillingTask]
          end
          let(:all_inaccessible_task_klasses) do
            ::Task.descendants - accessible_task_klasses
          end

          it 'can :view and :edit all accessible_task_klasses' do
            accessible_task_klasses.each do |klass|
              expect(permissions).to include(
                Permission.find_by(action: :view, applies_to: klass.name),
                permissions_with_editable_paper_states.where(
                  action: 'edit',
                  applies_to: klass.name
                ).first
              )
            end

            all_inaccessible_task_klasses.each do |klass|
              expect(permissions).to_not include(
                Permission.find_by(action: :view, applies_to: klass.name),
                permissions_with_editable_paper_states.where(
                  action: 'edit',
                  applies_to: klass.name
                ).first
              )
            end
          end

          it 'can view/manage participants on all accessible_task_klasses' do
            accessible_task_klasses.each do |klass|
              expect(permissions).to include(
                Permission.find_by(action: :view_participants, applies_to: klass.name),
                Permission.find_by(action: :manage_participant, applies_to: klass.name)
              )
            end

            all_inaccessible_task_klasses.each do |klass|
              expect(permissions).to_not include(
                Permission.find_by(action: :view_participants, applies_to: klass.name),
                Permission.find_by(action: :manage_participant, applies_to: klass.name)
              )
            end
          end
        end
      end

      context 'Cover Editor role' do
        let(:permissions) { journal.cover_editor_role.permissions }

        context 'has Paper permission to' do
          it ':view' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'edit')
            )
          end

          it ':edit_authors' do
            expect(permissions).to include(
              permissions_on_paper_with_editable_paper_states
                .find_by(action: 'edit_authors')
            )
          end

          it ':manage_workflow' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'manage_workflow')
            )
          end

          it ':manage_collaborators' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'manage_collaborators')
            )
          end

          it ':register_decision' do
            expect(permissions).to include(
              permissions_on_paper_with_submitted_state
                .find_by(action: 'register_decision')
            )
          end

          it ':start_discussion' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'start_discussion')
            )
          end

          it ':submit' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'submit')
            )
          end

          it ':view_user_role_eligibility_on_paper' do
            expect(permissions).to include(
              permissions_on_paper.find_by(
                action: 'view_user_role_eligibility_on_paper'
              )
            )
          end

          it ':assign_roles' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'assign_roles')
            )
          end

          it ':search_academic_editors' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_academic_editors')
            )
          end

          it ':search_admins' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_admins')
            )
          end

          it ':search_reviewers' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_reviewers')
            )
          end
        end

        context 'has Task permission to' do
          it ':view' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_with_editable_paper_states.where(
                action: 'edit',
                applies_to: 'Task'
              ).first
            )
          end

          it ':manage_participant' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'manage_participant')
            )
          end

          it ':manage_invitations' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'manage_invitations')
            )
          end
        end

        context 'has DiscussionTopic permission to' do
          it ':view' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'edit')
            )
          end

          it ':manage_participant' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'manage_participant')
            )
          end

          it ':reply' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'reply')
            )
          end
        end

        describe 'permission to PlosBilling::BillingTask' do
          it 'cannot :view or :edit' do
            expect(permissions).not_to include(
              Permission.find_by(action: 'view', applies_to: 'PlosBilling::BillingTask'),
              Permission.find_by(action: 'edit', applies_to: 'PlosBilling::BillingTask')
            )
          end
        end
      end

      context 'Academic Editor' do
        let(:permissions) { journal.academic_editor_role.permissions }

        describe 'permissions on tasks' do
          let(:accessible_task_klasses) do
            accessible_for_role = ::Task.submission_task_types + [TahiStandardTasks::ReviewerReportTask]
            accessible_for_role - inaccessible_task_klasses
          end
          let(:inaccessible_task_klasses) do
            [PlosBilling::BillingTask, TahiStandardTasks::RegisterDecisionTask]
          end
          let(:all_inaccessible_task_klasses) do
            ::Task.descendants - accessible_task_klasses
          end
          let(:editable_state_ids) do
            PermissionState.where(name: Paper::EDITABLE_STATES).pluck(:id)
          end

          it 'can :view all accessible_task_klasses' do
            accessible_task_klasses.each do |klass|
              expect(permissions).to include(
                Permission.find_by(action: :view, applies_to: klass.name)
              )
            end

            all_inaccessible_task_klasses.each do |klass|
              expect(permissions).to_not include(
                Permission.find_by(action: :view, applies_to: klass.name)
              )
            end
          end

          it 'is able to view and edit the ReviewerRecommendationsTask' do
            expect(permissions).to include(
              Permission.where(action: 'view', applies_to: 'TahiStandardTasks::ReviewerRecommendationsTask').last
            )
            expect(permissions).to include(
              Permission.where(action: 'edit', applies_to: 'TahiStandardTasks::ReviewerRecommendationsTask').last
            )
          end
        end
      end

      context 'Handling Editor' do
        let(:permissions) { journal.handling_editor_role.permissions }

        context 'has Paper permission to' do
          it ':manage_workflow' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'manage_workflow')
            )
          end

          it ':view' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_paper_with_editable_paper_states
                .find_by(action: 'edit')
            )
          end

          it ':manage_collaborators' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'manage_collaborators')
            )
          end

          it ':edit_authors' do
            expect(permissions).to include(
              permissions_on_paper_with_editable_paper_states
                .find_by(action: 'edit_authors')
            )
          end

          it ':register_decision' do
            expect(permissions).to include(
              permissions_on_paper_with_submitted_state
                .find_by(action: 'register_decision')
            )
          end

          it ':start_discussion' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'start_discussion')
            )
          end

          it ':submit' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'submit')
            )
          end

          it ':search_academic_editors' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_academic_editors')
            )
          end

          it ':search_admins' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_admins')
            )
          end

          it ':search_reviewers' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_reviewers')
            )
          end
        end

        context 'has Task permission to' do
          it ':view' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_with_editable_paper_states.find_by(
                applies_to: 'Task',
                action: 'edit'
              )
            )
          end

          it ':view_participants' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'view_participants')
            )
          end

          it ':manage_participant' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'manage_participant')
            )
          end

          it ':add_email_participants' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'add_email_participants')
            )
          end

          it ':manage_invitations' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'manage_invitations')
            )
          end
        end

        context 'has DiscussionTopic permission to' do
          it ':view' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'edit')
            )
          end

          it ':manage_participant' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'manage_participant')
            )
          end

          it ':reply' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'reply')
            )
          end
        end

        describe 'permission to PlosBilling::BillingTask' do
          it 'cannot :view or :edit' do
            expect(permissions).not_to include(
              Permission.find_by(action: 'view', applies_to: 'PlosBilling::BillingTask'),
              Permission.find_by(action: 'edit', applies_to: 'PlosBilling::BillingTask')
            )
          end
        end
      end

      context 'Internal Editor' do
        let(:permissions) { journal.internal_editor_role.permissions }

        context 'has Journal permission to' do
          it ':view_paper_tracker' do
            expect(permissions).to include(
              permissions_on_journal.find_by(action: 'view_paper_tracker')
            )
          end
        end

        context 'has Paper permission to' do
          it ':manage_workflow' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'manage_workflow')
            )
          end

          it ':view' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'edit')
            )
          end

          it ':edit_authors' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'edit_authors')
            )
          end

          it ':manage_collaborators' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'manage_collaborators')
            )
          end

          it ':reactivate' do
            expect(journal.staff_admin_role.permissions).to include(
              permissions_on_paper_with_withdrawn_state
                .find_by(action: 'reactivate')
            )
          end
          it ':register_decision' do
            expect(permissions).to include(
              permissions_on_paper_with_submitted_state
                .find_by(action: 'register_decision')
            )
          end

          it ':start_discussion' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'start_discussion')
            )
          end

          it ':submit' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'submit')
            )
          end

          it ':withdraw' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'withdraw')
            )
          end

          it ':search_academic_editors' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_academic_editors')
            )
          end

          it ':search_admins' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_admins')
            )
          end

          it ':search_reviewers' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_reviewers')
            )
          end

          it ':send_to_apex' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'send_to_apex')
            )
          end
        end

        context 'has Task permission to' do
          it ':view' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'edit')
            )
          end

          it ':view_participants' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'view_participants')
            )
          end

          it ':manage_participant' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'manage_participant')
            )
          end

          it ':add_email_participants' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'add_email_participants')
            )
          end

          it ':manage_invitations' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'manage_invitations')
            )
          end
        end

        context 'has DiscussionTopic permission to' do
          it ':view' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'edit')
            )
          end

          it ':manage_participant' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'manage_participant')
            )
          end

          it ':reply' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'reply')
            )
          end
        end

        describe 'permission to PlosBilling::BillingTask' do
          it 'cannot :view or :edit' do
            expect(permissions).not_to include(
              Permission.find_by(action: 'view', applies_to: 'PlosBilling::BillingTask'),
              Permission.find_by(action: 'edit', applies_to: 'PlosBilling::BillingTask')
            )
          end
        end
      end

      context 'Production Staff' do
        let(:permissions) { journal.production_staff_role.permissions }

        context 'has Journal permission to' do
          it ':view_paper_tracker' do
            expect(permissions).to include(
              permissions_on_journal.find_by(action: 'view_paper_tracker')
            )
          end
        end

        context 'has Paper permission to' do
          it ':manage_workflow' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'manage_workflow')
            )
          end

          it ':view' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'edit')
            )
          end

          it ':edit_authors' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'edit_authors')
            )
          end

          it ':manage_collaborators' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'manage_collaborators')
            )
          end

          it ':reactivate' do
            expect(journal.staff_admin_role.permissions).to include(
              permissions_on_paper_with_withdrawn_state
                .find_by(action: 'reactivate')
            )
          end

          it ':register_decision' do
            expect(permissions).to include(
              permissions_on_paper_with_submitted_state
                .find_by(action: 'register_decision')
            )
          end

          it ':start_discussion' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'start_discussion')
            )
          end

          it ':submit' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'submit')
            )
          end

          it ':withdraw' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'withdraw')
            )
          end

          it ':search_academic_editors' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_academic_editors')
            )
          end

          it ':search_admins' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_admins')
            )
          end

          it ':search_reviewers' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_reviewers')
            )
          end

          it ':send_to_apex' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'send_to_apex')
            )
          end
        end

        context 'has Task permission to' do
          it ':view' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              Permission.joins(:states).where(
                action: 'edit',
                applies_to: 'Task',
                permission_states: { id: PermissionState.wildcard }
              ).first
            )
          end

          it ':view_participants' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'view_participants')
            )
          end

          it ':manage_participant' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'manage_participant')
            )
          end

          it ':add_email_participants' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'add_email_participants')
            )
          end

          it ':manage_invitations' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'manage_invitations')
            )
          end
        end

        context 'has DiscussionTopic permission to' do
          it ':view' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'edit')
            )
          end

          it ':manage_participant' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'manage_participant')
            )
          end

          it ':reply' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'reply')
            )
          end
        end

        describe 'permission to PlosBilling::BillingTask' do
          it ':view and :edit' do
            expect(permissions).to include(
              Permission.find_by(action: 'view', applies_to: 'PlosBilling::BillingTask'),
              Permission.joins(:states).where(
                action: 'edit',
                applies_to: 'PlosBilling::BillingTask',
                permission_states: { id: PermissionState.wildcard }).first
            )
          end
        end
      end

      context 'Publishing Services' do
        let(:permissions) { journal.publishing_services_role.permissions }

        context 'has Journal permission to' do
          it ':view_paper_tracker' do
            expect(permissions).to include(
              permissions_on_journal.find_by(action: 'view_paper_tracker')
            )
          end
        end

        context 'has Paper permission to' do
          it ':manage_workflow' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'manage_workflow')
            )
          end

          it ':view' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'edit')
            )
          end

          it ':edit_authors' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'edit_authors')
            )
          end

          it ':manage_collaborators' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'manage_collaborators')
            )
          end

          it ':reactivate' do
            expect(journal.staff_admin_role.permissions).to include(
              permissions_on_paper_with_withdrawn_state
                .find_by(action: 'reactivate')
            )
          end

          it ':register_decision' do
            expect(permissions).to include(
              permissions_on_paper_with_submitted_state
                .find_by(action: 'register_decision')
            )
          end

          it ':start_discussion' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'start_discussion')
            )
          end

          it ':submit' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'submit')
            )
          end

          it ':withdraw' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'withdraw')
            )
          end

          it ':search_academic_editors' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_academic_editors')
            )
          end

          it ':search_admins' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_admins')
            )
          end

          it ':search_reviewers' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_reviewers')
            )
          end

          it ':send_to_apex' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'send_to_apex')
            )
          end
        end

        context 'has Task permission to' do
          it ':view' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'edit')
            )
          end

          it ':view_participants' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'view_participants')
            )
          end

          it ':manage_participant' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'manage_participant')
            )
          end

          it ':add_email_participants' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'add_email_participants')
            )
          end

          it ':manage_invitations' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'manage_invitations')
            )
          end
        end

        context 'has DiscussionTopic permission to' do
          it ':view' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'edit')
            )
          end

          it ':manage_participant' do
            expect(permissions).to include(
              permissions_on_discussion_topic
                .find_by(action: 'manage_participant')
            )
          end

          it ':reply' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'reply')
            )
          end
        end

        describe 'permission to PlosBilling::BillingTask' do
          it ':view and :edit' do
            expect(permissions).to include(
              Permission.find_by(action: 'view', applies_to: 'PlosBilling::BillingTask'),
              Permission.joins(:states).where(
                action: 'edit',
                applies_to: 'PlosBilling::BillingTask',
                permission_states: { id: PermissionState.wildcard }
              ).first
            )
          end
        end
      end

      context 'Reviewer' do
        let(:permissions) { journal.reviewer_role.permissions }

        describe 'has Paper permission to' do
          it 'can :view associated Paper' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: :view)
            )
          end
        end

        describe 'has Task permission to' do
          let(:accessible_task_klasses) do
            Task.submission_task_types - inaccessible_task_klasses
          end
          let(:inaccessible_task_klasses) do
            [
              PlosBilling::BillingTask,
              TahiStandardTasks::CoverLetterTask,
              TahiStandardTasks::ReviewerRecommendationsTask
            ]
          end
          let(:all_inaccessible_task_klasses) do
            ::Task.descendants - accessible_task_klasses
          end

          it 'can :view and :view_participants on accessible task klasses' do
            accessible_task_klasses.each do |klass|
              klass_permissions = Permission.where(applies_to: klass.name)
              expect(permissions).to include(
                klass_permissions.find_by(action: :view),
                klass_permissions.find_by(action: :view_participants)
              )
            end
          end

          it 'cannot :view or :view_participants on inaccessible task klasses' do
            all_inaccessible_task_klasses.each do |klass|
              klass_permissions = Permission.where(applies_to: klass.name)
              expect(permissions).to_not include(
                klass_permissions.find_by(action: :view),
                klass_permissions.find_by(action: :view_participants)
              )
            end
          end
        end
      end

      context 'Staff Admin' do
        let(:permissions) { journal.staff_admin_role.permissions }

        context 'has Journal permission to' do
          it ':administer' do
            expect(permissions).to include(
              permissions_on_journal.find_by(action: 'administer')
            )
          end

          it ':view_paper_tracker' do
            expect(permissions).to include(
              permissions_on_journal.find_by(action: 'view_paper_tracker')
            )
          end
        end

        context 'has Paper permission to' do
          it ':manage_workflow' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'manage_workflow')
            )
          end

          it ':view' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'edit')
            )
          end

          it ':edit_authors' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'edit_authors')
            )
          end

          it ':manage_collaborators' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'manage_collaborators')
            )
          end

          it ':reactivate' do
            expect(permissions).to include(
              permissions_on_paper_with_withdrawn_state
                .find_by(action: 'reactivate')
            )
          end

          it ':register_decision' do
            expect(permissions).to include(
              permissions_on_paper_with_submitted_state
                .find_by(action: 'register_decision')
            )
          end

          it ':start_discussion' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'start_discussion')
            )
          end

          it ':submit' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'submit')
            )
          end

          it ':withdraw' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'withdraw')
            )
          end

          it ':search_academic_editors' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_academic_editors')
            )
          end

          it ':search_admins' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_admins')
            )
          end

          it ':search_reviewers' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'search_reviewers')
            )
          end

          it ':send_to_apex' do
            expect(permissions).to include(
              permissions_on_paper.find_by(action: 'send_to_apex')
            )
          end
        end

        context 'has DiscussionTopic permission to' do
          it ':view' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'edit')
            )
          end

          it ':manage_participant' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'manage_participant')
            )
          end
        end

        context 'has Task permission to' do
          it ':view' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'edit')
            )
          end

          it ':view_participants' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'view_participants')
            )
          end

          it ':manage_participant' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'manage_participant')
            )
          end

          it ':manage_invitations' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'manage_invitations')
            )
          end

          it ':add_email_participants' do
            expect(permissions).to include(
              permissions_on_task.find_by(action: 'add_email_participants')
            )
          end
        end

        context 'has DiscussionTopic permission to' do
          let(:permissions) { Permission.joins(:states).where(applies_to: 'DiscussionTopic', permission_states: { id: PermissionState.wildcard }) }

          it ':view' do
            expect(permissions).to include(
              permissions.find_by(action: 'view')
            )
          end

          it ':edit' do
            expect(permissions).to include(
              permissions.find_by(action: 'edit')
            )
          end

          it ':manage_participant' do
            expect(permissions).to include(
              permissions.find_by(action: 'manage_participant')
            )
          end

          it ':reply' do
            expect(permissions).to include(
              permissions.find_by(action: 'reply')
            )
          end
        end

        describe 'permission to PlosBilling::BillingTask' do
          it ':view and :edit' do
            expect(permissions).to include(
              Permission.find_by(action: 'view', applies_to: 'PlosBilling::BillingTask'),
              Permission.joins(:states).where(
                action: 'edit',
                applies_to: 'PlosBilling::BillingTask',
                permission_states: { id: PermissionState.wildcard }
              ).first
            )
          end
        end
      end
    end
  end
end
