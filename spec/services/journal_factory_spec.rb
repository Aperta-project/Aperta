require 'rails_helper'

describe JournalFactory, flaky: true do
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
    let(:billing_task_klasses) do
      [PlosBilling::BillingTask] +
        PlosBilling::BillingTask.descendants
    end
    let(:restricted_invite_klasses) do
      [TahiStandardTasks::PaperEditorTask]
    end
    let(:changes_for_author_task_klasses) do
      [PlosBioTechCheck::ChangesForAuthorTask] +
        PlosBioTechCheck::ChangesForAuthorTask.descendants
    end
    let(:reviewer_report_klasses) do
      [TahiStandardTasks::ReviewerReportTask] +
        TahiStandardTasks::ReviewerReportTask.descendants
    end
    let(:tech_check_klasses) do
      [
        PlosBioTechCheck::InitialTechCheckTask,
        PlosBioTechCheck::RevisionTechCheckTask,
        PlosBioTechCheck::FinalTechCheckTask
      ] +
        PlosBioTechCheck::InitialTechCheckTask.descendants +
        PlosBioTechCheck::RevisionTechCheckTask.descendants +
        PlosBioTechCheck::FinalTechCheckTask.descendants
    end

    it 'creates a new journal with the given params' do
      expect do
        journal = JournalFactory.create(name: 'Journal of the Stars')
        expect(journal.name).to eq('Journal of the Stars')
      end.to change(Journal, :count).by(1)
    end

    context 'role hints' do
      let!(:journal) { JournalFactory.create(name: 'Journal of the Stars') }

      it 'assigns hints to discussion topic roles' do
        expect(Role::DISCUSSION_TOPIC_ROLES.sort).to \
          eq(journal.roles.where(assigned_to_type_hint: DiscussionTopic.name).map(&:name))
      end

      it 'assigns hints to task roles' do
        expect(journal.roles.where(assigned_to_type_hint: Task.name).map(&:name).sort)
          .to eq(Role::TASK_ROLES.sort)
      end

      it 'assigns paper hints to paper roles' do
        expect(journal.roles.where(assigned_to_type_hint: Paper.name).map(&:name).sort)
          .to eq(Role::PAPER_ROLES.sort)
      end

      it 'assigns journal hints to journal roles' do
        expect(journal.roles.where(assigned_to_type_hint: Journal.name).map(&:name).sort)
          .to eq(Role::JOURNAL_ROLES.sort)
      end
    end

    context 'creating the default roles and permission for the journal', flaky: true do
      before(:all) do
        @journal = JournalFactory.create(name: 'Genetics Journal')
      end

      after(:all) do
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
          let(:paper_actions) do
            [
              'submit',
              'view',
              'withdraw'
            ]
          end

          it 'has all paper permissions' do
            paper_actions.each do |action|
              expect(permissions).to include(
                permissions_on_paper.find_by(action: action)
              ), action
            end
          end

          it ':edit' do
            expect(permissions).to include(
              permissions_on_paper_with_editable_paper_states
                .find_by(action: 'edit')
            )
          end

          it ':edit_authors' do
            expect(permissions).to include(
              permissions_on_paper_with_editable_paper_states
                .find_by(action: 'edit_authors')
            )
          end
        end

        describe 'permissions on tasks' do
          let(:submission_task_klasses) { ::Task.submission_task_types }
          let(:inaccessible_task_klasses) do
            ::Task.descendants -
              submission_task_klasses -
              changes_for_author_task_klasses -
              [AdHocForAuthorsTask]
          end

          it <<-DESC.strip_heredoc do
            can :view submission tasks in any state
          DESC
            expected_view_permissions = Permission.joins(:states).where(
              action: 'view',
              applies_to: submission_task_klasses.map(&:name),
              permission_states: { name: PermissionState.wildcard.name }
            ).all
            expect(permissions).to include(*expected_view_permissions)
          end

          it <<-DESC.strip_heredoc do
            can :edit all submission tasks when the paper is in an editable state
          DESC
            expected_edit_permissions = Permission.joins(:states).where(
              action: 'edit',
              applies_to: submission_task_klasses.map(&:name),
              permission_states: { name: Paper::EDITABLE_STATES }
            ).all
            expect(permissions).to include(*expected_edit_permissions)
          end

          it 'has no permissions on inaccessible tasks' do
            expect(permissions).to_not include(
              *Permission.where(
                applies_to: inaccessible_task_klasses.map(&:name)
              ).all
            )
          end

          it <<-DESC.strip_heredoc do
            can :view the PlosBioTechCheck ChangesForAuthorTask in any paper state
            can :edit the PlosBioTechCheck ChangesForAuthorTask in editable paper states
          DESC
            task_klass_names = changes_for_author_task_klasses.map(&:name)
            expected_view_permissions = Permission.joins(:states).where(
              action: 'view',
              applies_to: task_klass_names,
              permission_states: { name: PermissionState.wildcard.name }
            ).all
            expect(permissions).to include(*expected_view_permissions)

            expected_edit_permissions = Permission.joins(:states).where(
              action: 'edit',
              applies_to: task_klass_names,
              permission_states: { name: Paper::EDITABLE_STATES }
            ).all
            expect(permissions).to include(*expected_edit_permissions)
          end

          it <<-DESC.strip_heredoc do
            can :view the AdHocForAuthorTask in any paper state
            can :edit the AdHocForAuthorTask in editable paper states
          DESC
            expected_view_permissions = Permission.joins(:states).where(
              action: 'view',
              applies_to: 'AdHocForAuthorTask',
              permission_states: { name: PermissionState.wildcard.name }
            ).all
            expect(permissions).to include(*expected_view_permissions)

            expected_edit_permissions = Permission.joins(:states).where(
              action: 'edit',
              applies_to: 'AdHocForAuthorTask',
              permission_states: { name: Paper::EDITABLE_STATES }
            ).all
            expect(permissions).to include(*expected_edit_permissions)
          end

          it 'can view/add/remove participants on all submission tasks except ProductionMetadataTask' do
            submission_task_klasses.each do |klass|
              expect(permissions).to include(
                Permission.find_by(action: :view_participants, applies_to: klass.name),
                Permission.find_by(action: :manage_participant, applies_to: klass.name)
              )
            end
          end

          it 'can do nothing on any of the PlosBioTechCheck tasks' do
            tech_check_permissions = Permission.where(
              applies_to: tech_check_klasses.map(&:name)
            ).all
            expect(permissions).not_to include(*tech_check_permissions)
          end
        end
      end

      it 'gives the journal its own Collaborator role' do
        expect(journal.collaborator_role).to be
      end

      context 'Collaborator role' do
        let(:permissions) { journal.collaborator_role.permissions }

        context 'has Paper permission to' do
          let(:paper_actions) do
            [
              'submit',
              'view'
            ]
          end

          it 'has all paper permissions' do
            paper_actions.each do |action|
              expect(permissions).to include(
                permissions_on_paper.find_by(action: action)
              )
            end
          end
        end

        describe 'permissions on tasks' do
          let(:accessible_task_klasses) do
            accessible_for_role = ::Task.descendants.select do |klass|
              klass <=> SubmissionTask
            end
            accessible_for_role << AdHocForAuthorsTask
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

          it 'can do nothing on any of the PlosBioTechCheck tasks' do
            tech_check_permissions = Permission.where(
              applies_to: tech_check_klasses.map(&:name)
            ).all
            expect(permissions).not_to include(*tech_check_permissions)
          end
        end
      end

      context 'Cover Editor role' do
        let(:permissions) { journal.cover_editor_role.permissions }

        context 'has Paper permission to' do
          let(:paper_actions) do
            [
              'assign_roles',
              'edit',
              'edit_related_articles',
              'manage_collaborators',
              'manage_workflow',
              'register_decision',
              'search_academic_editors',
              'search_admins',
              'search_reviewers',
              'start_discussion',
              'submit',
              'view',
              'view_decisions',
              'view_user_role_eligibility_on_paper'
            ]
          end

          it 'has all paper permissions' do
            paper_actions.each do |action|
              expect(permissions).to include(
                permissions_on_paper.find_by(action: action)
              ), action
            end
          end

          it ':edit_authors' do
            expect(permissions).to include(
              permissions_on_paper_with_editable_paper_states
                .find_by(action: 'edit_authors')
            )
          end
        end

        describe 'Task permissions' do
          let(:task_klasses) do
            ::Task.descendants -
              billing_task_klasses -
              changes_for_author_task_klasses -
              restricted_invite_klasses
          end
          let(:non_editable_task_klasses) { reviewer_report_klasses }
          let(:editable_task_klasses_based_on_paper_state) do
            task_klasses -
              non_editable_task_klasses -
              editable_task_klasses_regardless_of_paper_state
          end
          let(:editable_task_klasses_regardless_of_paper_state) do
            [TahiStandardTasks::TitleAndAbstractTask]
          end

          it <<-DESC do
            can :add_email_participants on all Tasks
            can :manage on all Tasks
            can :manage_invitations on all Tasks
            can :manage_participant on all Tasks
            can :view on all Tasks
            can :view_participants  on all Tasks
          DESC
            task_klasses.each do |klass|
              expect(permissions).to include(
                Permission.find_by(action: :add_email_participants, applies_to: klass.name),
                Permission.find_by(action: :manage, applies_to: klass.name),
                Permission.find_by(action: :manage_invitations, applies_to: klass.name),
                Permission.find_by(action: :manage_participant, applies_to: klass.name),
                Permission.find_by(action: :view, applies_to: klass.name),
                Permission.find_by(action: :view_participants, applies_to: klass.name)
              )
            end
          end

          it <<-DESC do
            can :edit all Tasks except ReviewerReportTasks(s) when the
            paper is in an editable state
          DESC
            editable_task_klasses_based_on_paper_state.each do |klass|
              permission = Permission.joins(:states).find_by(
                action: 'edit',
                applies_to: klass.name,
                permission_states: { name: Paper::EDITABLE_STATES }
              )
              expect(permissions).to include(permission)
            end

            reviewer_report_klasses.each do |klass|
              expect(permissions).to_not include(
                Permission.find_by(action: 'edit', applies_to: klass.name)
              )
            end
          end

          it 'can :edit TitleAndAbstractTask regardless of paper state' do
            editable_task_klasses_regardless_of_paper_state.each do |klass|
              permission = Permission.find_by(
                action: 'edit',
                applies_to: klass.name
              )
              expect(permissions).to include(permission)
              expect(permission.states).to contain_exactly(
                PermissionState.wildcard
              )
            end
          end

          it 'can do nothing on the PlosBilling::BillingTask' do
            billing_permissions = Permission.where(
              applies_to: 'PlosBilling::BillingTask'
            ).all
            expect(permissions).not_to include(*billing_permissions)
          end

          it 'can do nothing on the PlosBioTechCheck::ChangesForAuthorTask' do
            changes_for_author_permissions = Permission.where(
              applies_to: 'PlosBioTechCheck::ChangesForAuthorTask'
            ).all
            expect(permissions).not_to include(*changes_for_author_permissions)
          end
        end

        context 'has DiscussionTopic permission to' do
          let(:discussion_topic_actions) do
            [
              'edit',
              'manage_participant',
              'reply',
              'view'
            ]
          end

          it 'has all discussion topic permissions' do
            discussion_topic_actions.each do |action|
              expect(permissions).to include(
                permissions_on_discussion_topic.find_by(action: action)
              ), action
            end
          end
        end
      end

      context 'Discussion Participant' do
        let(:permissions) { journal.discussion_participant_role.permissions }

        describe 'has discussion reply permission to' do
          specify ':view' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'view')
            )
          end
          specify ':reply' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'reply')
            )
          end
          specify ':be_at_mentioned' do
            expect(permissions).to include(
              permissions_on_discussion_topic.find_by(action: 'be_at_mentioned')
            )
          end
        end
      end

      context 'Academic Editor' do
        let(:permissions) { journal.academic_editor_role.permissions }

        describe 'permissions on tasks' do
          let(:accessible_task_klasses) do
            accessible_for_role = ::Task.submission_task_types
            accessible_for_role << TahiStandardTasks::ReviewerReportTask
            accessible_for_role << AdHocForEditorsTask
            accessible_for_role - inaccessible_task_klasses
          end
          let(:inaccessible_task_klasses) do
            [PlosBilling::BillingTask,
             TahiStandardTasks::RegisterDecisionTask]
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

          it 'can :edit and :view AdHocForEditorsTasks' do
            [:edit, :view].each do |action|
              expect(permissions).to include(
                Permission.find_by(action: action, applies_to: AdHocForEditorsTask.name)
              )
            end
          end

          it 'is not able to edit the ReviewerRecommendationsTask' do
            expect(permissions).to_not include(
              Permission.where(action: 'edit', applies_to: 'TahiStandardTasks::ReviewerRecommendationsTask').last
            )
          end

          it 'is not able to edit the ReviewerReportTask(s)' do
            reviewer_report_klasses.each do |klass|
              expect(permissions).to_not include(
                Permission.find_by(
                  action: 'edit',
                  applies_to: klass.name
                )
              )
            end
          end

          it 'can do nothing on the PlosBioTechCheck::ChangesForAuthorTask' do
            changes_for_author_permissions = Permission.where(
              applies_to: 'PlosBioTechCheck::ChangesForAuthorTask'
            ).all
            expect(permissions).not_to include(*changes_for_author_permissions)
          end

          it 'can do nothing on any of the PlosBioTechCheck tasks' do
            tech_check_permissions = Permission.where(
              applies_to: tech_check_klasses.map(&:name)
            ).all
            expect(permissions).not_to include(*tech_check_permissions)
          end
        end
      end

      context 'Freelance Editor' do
        let(:permissions) { journal.freelance_editor_role.permissions }

        it 'has no permissions' do
          expect(permissions).to be_empty
        end
      end

      context 'Handling Editor' do
        let(:permissions) { journal.handling_editor_role.permissions }

        context 'has Paper permission to' do
          let(:paper_actions) do
            [
              'assign_roles',
              'edit_related_articles',
              'manage_collaborators',
              'manage_workflow',
              'register_decision',
              'rescind_decision',
              'search_academic_editors',
              'search_admins',
              'search_reviewers',
              'start_discussion',
              'submit',
              'view',
              'view_decisions',
              'view_user_role_eligibility_on_paper'
            ]
          end
          let(:editable_paper_actions) { ['edit', 'edit_authors'] }

          it 'has all paper permissions' do
            paper_actions.each do |action|
              expect(permissions).to include(
                permissions_on_paper.find_by(action: action)
              ), action
            end
          end

          it 'has editable state permissions' do
            editable_paper_actions.each do |action|
              expect(permissions).to include(
                permissions_on_paper_with_editable_paper_states
                  .find_by(action: action)
              )
            end
          end

          it 'has no additional paper permissions' do
            all_paper_actions = paper_actions + editable_paper_actions
            expect(
              permissions.where(applies_to: 'Paper').map(&:action) - all_paper_actions
            ).to eq([])
          end
        end

        describe 'Task permissions' do
          let(:task_klasses) do
            ::Task.descendants -
              billing_task_klasses -
              changes_for_author_task_klasses -
              restricted_invite_klasses
          end
          let(:non_editable_task_klasses) { reviewer_report_klasses }
          let(:editable_task_klasses_based_on_paper_state) do
            task_klasses -
              non_editable_task_klasses -
              editable_task_klasses_regardless_of_paper_state
          end
          let(:editable_task_klasses_regardless_of_paper_state) do
            [TahiStandardTasks::TitleAndAbstractTask]
          end

          it <<-DESC do
            can :add_email_participants on all Tasks
            can :manage on all Tasks
            can :manage_invitations on all Tasks
            can :manage_participant on all Tasks
            can :view on all Tasks
            can :view_participants  on all Tasks
          DESC
            task_klasses.each do |klass|
              expect(permissions).to include(
                Permission.find_by(action: :add_email_participants, applies_to: klass.name),
                Permission.find_by(action: :manage, applies_to: klass.name),
                Permission.find_by(action: :manage_invitations, applies_to: klass.name),
                Permission.find_by(action: :manage_participant, applies_to: klass.name),
                Permission.find_by(action: :view, applies_to: klass.name),
                Permission.find_by(action: :view_participants, applies_to: klass.name)
              )
            end
          end

          it <<-DESC do
            can :edit all Tasks except ReviewerReportTasks(s) when the
            paper is in an editable state
          DESC
            editable_task_klasses_based_on_paper_state.each do |klass|
              permission = Permission.joins(:states).find_by(
                action: 'edit',
                applies_to: klass.name,
                permission_states: { name: Paper::EDITABLE_STATES }
              )
              expect(permissions).to include(permission)
            end

            reviewer_report_klasses.each do |klass|
              expect(permissions).to_not include(
                Permission.find_by(action: 'edit', applies_to: klass.name)
              )
            end
          end

          it 'can :edit TitleAndAbstractTask regardless of paper state' do
            editable_task_klasses_regardless_of_paper_state.each do |klass|
              permission = Permission.find_by(
                action: 'edit',
                applies_to: klass.name
              )
              expect(permissions).to include(permission)
              expect(permission.states).to contain_exactly(
                PermissionState.wildcard
              )
            end
          end

          it 'can do nothing on the PlosBilling::BillingTask' do
            billing_permissions = Permission.where(
              applies_to: 'PlosBilling::BillingTask'
            ).all
            expect(permissions).not_to include(*billing_permissions)
          end

          it 'can do nothing on the PlosBioTechCheck::ChangesForAuthorTask' do
            changes_for_author_permissions = Permission.where(
              applies_to: 'PlosBioTechCheck::ChangesForAuthorTask'
            ).all
            expect(permissions).not_to include(*changes_for_author_permissions)
          end
        end

        context 'has DiscussionTopic permission to' do
          let(:discussion_topic_actions) do
            [
              'edit',
              'manage_participant',
              'reply',
              'view'
            ]
          end

          it 'has all discussion topic permissions' do
            discussion_topic_actions.each do |action|
              expect(permissions).to include(
                permissions_on_discussion_topic.find_by(action: action)
              )
            end
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
          let(:paper_actions) do
            [
              'assign_roles',
              'edit',
              'edit_authors',
              'edit_related_articles',
              'manage_collaborators',
              'manage_workflow',
              'register_decision',
              'rescind_decision',
              'search_academic_editors',
              'search_admins',
              'search_reviewers',
              'send_to_apex',
              'start_discussion',
              'submit',
              'view',
              'view_decisions',
              'view_user_role_eligibility_on_paper',
              'withdraw'
            ]
          end

          it 'has all paper permissions' do
            paper_actions.each do |action|
              expect(permissions).to include(
                permissions_on_paper.find_by(action: action)
              ), action
            end
          end

          it 'has no additional paper permissions' do
            expect(permissions_on_paper.map(&:action) - paper_actions).to eq([])
          end

          it ':reactivate' do
            expect(journal.staff_admin_role.permissions).to include(
              permissions_on_paper_with_withdrawn_state
                .find_by(action: 'reactivate')
            )
          end
        end

        context 'has Task permission to' do
          let(:task_actions) do
            [
              'add_email_participants',
              'edit',
              'manage',
              'manage_invitations',
              'manage_participant',
              'view',
              'view_participants'
            ]
          end

          it <<-DESC do
            can :add_email_participants on all Tasks
            can :edit on all Tasks except billing tasks
            can :manage on all Tasks
            can :manage_invitations on all Tasks
            can :manage_participant on all Tasks
            can :view on all Tasks except billing tasks
            can :view_participants  on all Tasks
          DESC
            task_actions.each do |action|
              expect(permissions).to include(
                permissions_on_task.find_by(action: action)
              )
            end
          end

          it 'has no additional Task permissions' do
            expect(permissions_on_task.map(&:action) - task_actions).to eq([])
          end

          it 'cannot :view or :edit the PlosBilling::BillingTask' do
            expect(permissions).to_not include(
              Permission.find_by(action: 'view', applies_to: 'PlosBilling::BillingTask'),
              Permission.find_by(action: 'edit', applies_to: 'PlosBilling::BillingTask')
            )
          end
        end

        context 'has DiscussionTopic permission to' do
          let(:discussion_topic_actions) do
            [
              'be_at_mentioned',
              'edit',
              'manage_participant',
              'reply',
              'view'
            ]
          end

          it 'has all discussion topic permissions' do
            discussion_topic_actions.each do |action|
              expect(permissions).to include(
                permissions_on_discussion_topic.find_by(action: action)
              )
            end
          end

          it 'has no additional discussion topic permissions' do
            expect(permissions_on_discussion_topic.map(&:action) - discussion_topic_actions).to eq([])
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
          let(:paper_actions) do
            [
              'assign_roles',
              'edit',
              'edit_authors',
              'edit_related_articles',
              'manage_collaborators',
              'manage_workflow',
              'register_decision',
              'rescind_decision',
              'search_academic_editors',
              'search_admins',
              'search_reviewers',
              'send_to_apex',
              'start_discussion',
              'submit',
              'view',
              'view_decisions',
              'view_user_role_eligibility_on_paper',
              'withdraw'
            ]
          end

          it 'has all paper permissions' do
            paper_actions.each do |action|
              expect(permissions).to include(
                permissions_on_paper.find_by(action: action)
              ), action
            end
          end

          it 'has no additional paper permissions' do
            expect(permissions_on_paper.map(&:action) - paper_actions).to eq([])
          end

          it ':reactivate' do
            expect(journal.staff_admin_role.permissions).to include(
              permissions_on_paper_with_withdrawn_state
                .find_by(action: 'reactivate')
            )
          end
        end

        context 'has Task permission to' do
          let(:task_actions) do
            [
              'add_email_participants',
              'manage',
              'edit',
              'manage_invitations',
              'manage_participant',
              'view',
              'view_participants'
            ]
          end

          it <<-DESC do
            can :add_email_participants on all Tasks
            can :edit on all Tasks except billing tasks
            can :manage on all Tasks
            can :manage_invitations on all Tasks
            can :manage_participant on all Tasks
            can :view on all Tasks except billing tasks
            can :view_participants  on all Tasks
          DESC
            task_actions.each do |action|
              expect(permissions).to include(
                permissions_on_task.find_by(action: action)
              )
            end
          end

          it 'has no additional Task permissions' do
            expect(permissions_on_task.map(&:action) - task_actions).to eq([])
          end

          it 'cannot :view or :edit the PlosBilling::BillingTask' do
            expect(permissions).to_not include(
              Permission.find_by(action: 'view', applies_to: 'PlosBilling::BillingTask'),
              Permission.find_by(action: 'edit', applies_to: 'PlosBilling::BillingTask')
            )
          end
        end

        context 'has DiscussionTopic permission to' do
          let(:discussion_topic_actions) do
            [
              'be_at_mentioned',
              'edit',
              'manage_participant',
              'reply',
              'view'
            ]
          end

          it 'has all discussion topic permissions' do
            discussion_topic_actions.each do |action|
              expect(permissions).to include(
                permissions_on_discussion_topic.find_by(action: action)
              )
            end
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
          let(:paper_actions) do
            [
              'assign_roles',
              'edit',
              'edit_authors',
              'edit_related_articles',
              'manage_collaborators',
              'manage_workflow',
              'register_decision',
              'rescind_decision',
              'search_academic_editors',
              'search_admins',
              'search_reviewers',
              'send_to_apex',
              'start_discussion',
              'submit',
              'view',
              'view_decisions',
              'view_user_role_eligibility_on_paper',
              'withdraw'
            ]
          end

          it 'has all paper permissions' do
            paper_actions.each do |action|
              expect(permissions).to include(
                permissions_on_paper.find_by(action: action)
              ), action
            end
          end

          it 'has no additional paper permissions' do
            expect(permissions_on_paper.map(&:action) - paper_actions).to eq([])
          end

          it ':reactivate' do
            expect(journal.staff_admin_role.permissions).to include(
              permissions_on_paper_with_withdrawn_state
                .find_by(action: 'reactivate')
            )
          end
        end

        context 'has Task permission to' do
          let(:task_actions) do
            [
              'add_email_participants',
              'edit',
              'manage',
              'manage_invitations',
              'manage_participant',
              'view',
              'view_participants'
            ]
          end

          it <<-DESC do
            can :add_email_participants on all Tasks
            can :edit on all Tasks except billing tasks
            can :manage on all Tasks
            can :manage_invitations on all Tasks
            can :manage_participant on all Tasks
            can :view on all Tasks except billing tasks
            can :view_participants  on all Tasks
          DESC
            task_actions.each do |action|
              expect(permissions).to include(
                permissions_on_task.find_by(action: action)
              )
            end
          end

          it 'has no additional Task permissions' do
            expect(permissions_on_task.map(&:action) - task_actions).to eq([])
          end

          it 'cannot :view or :edit the PlosBilling::BillingTask' do
            expect(permissions).to_not include(
              Permission.find_by(action: 'view', applies_to: 'PlosBilling::BillingTask'),
              Permission.find_by(action: 'edit', applies_to: 'PlosBilling::BillingTask')
            )
          end
        end

        context 'has DiscussionTopic permission to' do
          let(:discussion_topic_actions) do
            [
              'be_at_mentioned',
              'edit',
              'manage_participant',
              'reply',
              'view'
            ]
          end

          it 'has all discussion topic permissions' do
            discussion_topic_actions.each do |action|
              expect(permissions).to include(
                permissions_on_discussion_topic.find_by(action: action)
              )
            end
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
            accessible_for_role = Task.submission_task_types
            accessible_for_role << AdHocForReviewersTask
            accessible_for_role - inaccessible_task_klasses
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

          it 'can do nothing on the PlosBilling::BillingTask' do
            billing_permissions = Permission.where(
              applies_to: 'PlosBilling::BillingTask'
            ).all
            expect(permissions).not_to include(*billing_permissions)
          end

          it 'can do nothing on the TahiStandardTasks::CoverLetterTask' do
            cover_letter_permissions = Permission.where(
              applies_to: 'TahiStandardTasks::CoverLetterTask'
            ).all
            expect(permissions).not_to include(*cover_letter_permissions)
          end

          it 'can do nothing on the TahiStandardTasks::RegisterDecisionTask' do
            register_decision_permissions = Permission.where(
              applies_to: 'TahiStandardTasks::RegisterDecisionTask'
            ).all
            expect(permissions).not_to include(*register_decision_permissions)
          end

          it 'can do nothing on the TahiStandardTasks::ReviewerRecommendationsTask' do
            reviewer_recommendations_permissions = Permission.where(
              applies_to: 'TahiStandardTasks::ReviewerRecommendationsTask'
            ).all
            expect(permissions).not_to include(*reviewer_recommendations_permissions)
          end

          it 'can do nothing on the PlosBilling::BillingTask' do
            billing_permissions = Permission.where(
              applies_to: 'PlosBilling::BillingTask'
            ).all
            expect(permissions).not_to include(*billing_permissions)
          end

          it 'can :edit AdHocTasksForReviewers' do
            permission = Permission.find_by(applies_to: 'AdHocForReviewersTask', action: :edit)
            expect(permission.states.map(&:name)).to contain_exactly(*Paper::REVIEWABLE_STATES.map(&:to_s))
            expect(journal.reviewer_role.permissions).to include permission
          end

          it 'can do nothing on the PlosBioTechCheck::ChangesForAuthorTask' do
            changes_for_author_permissions = Permission.where(
              applies_to: 'PlosBioTechCheck::ChangesForAuthorTask'
            ).all
            expect(permissions).not_to include(*changes_for_author_permissions)
          end

          it 'can do nothing on any of the PlosBioTechCheck tasks' do
            tech_check_permissions = Permission.where(
              applies_to: tech_check_klasses.map(&:name)
            ).all
            expect(permissions).not_to include(*tech_check_permissions)
          end
        end
      end

      context 'Reviewer Report Owner' do
        describe 'has Task permission to' do
          it 'can :edit assigned ReviewerReportTasks' do
            permission = Permission.includes(:states).find_by(
              applies_to: 'TahiStandardTasks::ReviewerReportTask',
              action: :edit
            )
            expect(permission.states.map(&:name)).to contain_exactly(*Paper::REVIEWABLE_STATES.map(&:to_s))
            expect(journal.reviewer_report_owner_role.permissions).to include(
              permission
            )
          end
        end
      end

      context 'Staff Admin' do
        let(:permissions) { journal.staff_admin_role.permissions }

        context 'has Journal permission to' do
          let(:journal_actions) { ['administer', 'view_paper_tracker'] }

          it 'has journal permissions' do
            journal_actions.each do |action|
              expect(permissions).to include(
                permissions_on_journal.find_by(action: action)
              )
            end
          end
        end

        context 'has Paper permission to' do
          let(:paper_actions) do
            [
              'edit',
              'edit_authors',
              'manage_collaborators',
              'manage_workflow',
              'register_decision',
              'search_academic_editors',
              'search_admins',
              'search_reviewers',
              'send_to_apex',
              'start_discussion',
              'submit',
              'view',
              'view_decisions',
              'withdraw'
            ]
          end

          it 'has all paper permissions' do
            paper_actions.each do |action|
              expect(permissions).to include(
                permissions_on_paper.find_by(action: action)
              )
            end
          end

          it ':reactivate' do
            expect(permissions).to include(
              permissions_on_paper_with_withdrawn_state
                .find_by(action: 'reactivate')
            )
          end
        end

        context 'has DiscussionTopic permission to' do
          let(:discussion_topic_actions) do
            [
              'be_at_mentioned',
              'edit',
              'manage_participant',
              'view'
            ]
          end

          it 'has all discussion topic permissions' do
            discussion_topic_actions.each do |action|
              expect(permissions).to include(
                permissions_on_discussion_topic.find_by(action: action)
              )
            end
          end
        end

        context 'has Task permission to' do
          let(:task_actions) do
            [
              'add_email_participants',
              'edit',
              'manage',
              'manage_invitations',
              'manage_participant',
              'view',
              'view_participants'
            ]
          end

          it <<-DESC do
            can :add_email_participants on all Tasks
            can :edit on all Tasks except billing tasks
            can :manage on all Tasks
            can :manage_invitations on all Tasks
            can :manage_participant on all Tasks
            can :view on all Tasks except billing tasks
            can :view_participants  on all Tasks
          DESC
            task_actions.each do |action|
              expect(permissions).to include(
                permissions_on_task.find_by(action: action)
              )
            end
          end

          it 'has no additional Task permissions' do
            expect(permissions_on_task.map(&:action) - task_actions).to eq([])
          end

          it 'cannot :view or :edit the PlosBilling::BillingTask' do
            expect(permissions).to_not include(
              Permission.find_by(action: 'view', applies_to: 'PlosBilling::BillingTask'),
              Permission.find_by(action: 'edit', applies_to: 'PlosBilling::BillingTask')
            )
          end
        end

        context 'has DiscussionTopic permission to' do
          let(:discussion_topic_actions) do
            [
              'edit',
              'manage_participant',
              'reply',
              'view'
            ]
          end

          it 'has all discussion topic permissions' do
            discussion_topic_actions.each do |action|
              expect(permissions).to include(
                permissions_on_discussion_topic.find_by(action: action)
              )
            end
          end
        end
      end

      context 'Billing staff' do
        let(:permissions) { journal.billing_role.permissions }

        describe 'permission to PlosBilling::BillingTask' do
          it 'can :view and :edit' do
            # Sometimes there is more than one 'edit' or 'view' permission for BillingTask so this fixes spec flakiness
            permission_strings = permissions.where(applies_to: 'PlosBilling::BillingTask').pluck(:action)
            expect(permission_strings).to contain_exactly('view', 'edit')
          end
        end
      end
    end
  end
end
