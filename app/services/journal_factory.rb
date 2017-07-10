# JournalFactory is for creating new journals in Aperta. It gets them all
# set up: nice and right.
class JournalFactory
  def self.create(journal_params)
    journal = Journal.new(journal_params)
    new(journal).create
  end

  def self.ensure_default_roles_and_permissions_exist(journal)
    new(journal).ensure_default_roles_and_permissions_exist
  end

  def self.assign_hints(journal)
    new(journal).assign_hints
  end

  def initialize(journal)
    @journal = journal
  end

  def create
    @journal.save!
    ensure_default_roles_and_permissions_exist
    assign_hints
    @journal
  end

  def assign_hint(names, hint)
    @journal.roles.where(name: names)
            .update_all(assigned_to_type_hint: hint)
  end

  def assign_hints
    assign_hint Role::DISCUSSION_TOPIC_ROLES, DiscussionTopic.name
    assign_hint Role::TASK_ROLES,             Task.name
    assign_hint Role::PAPER_ROLES,            Paper.name
    assign_hint Role::JOURNAL_ROLES,          Journal.name
  end

  # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/LineLength
  def ensure_default_roles_and_permissions_exist
    Role.ensure_exists(Role::CREATOR_ROLE, journal: @journal, participates_in: [Task, Paper]) do |role|
      # Paper
      role.ensure_permission_exists(:edit, applies_to: Paper, states: Paper::EDITABLE_STATES)
      role.ensure_permission_exists(:edit_authors, applies_to: Paper, states: Paper::EDITABLE_STATES)
      role.ensure_permission_exists(:submit, applies_to: Paper)
      role.ensure_permission_exists(:view, applies_to: Paper)
      role.ensure_permission_exists(:withdraw, applies_to: Paper)
      role.ensure_permission_exists(:view_recent_activity, applies_to: Paper)

      # Creator(s) only get access to the submission task types
      task_klasses = Task.submission_task_types
      task_klasses << PlosBioTechCheck::ChangesForAuthorTask
      task_klasses << AdHocForAuthorsTask
      task_klasses.each do |klass|
        role.ensure_permission_exists(:add_email_participants, applies_to: klass)
        role.ensure_permission_exists(:edit, applies_to: klass, states: Paper::EDITABLE_STATES)
        role.ensure_permission_exists(:manage_participant, applies_to: klass)
        role.ensure_permission_exists(:view, applies_to: klass)
        role.ensure_permission_exists(:view_participants, applies_to: klass)
      end
      role.ensure_permission_exists(:view, applies_to: CardVersion)
    end

    Role.ensure_exists(Role::COLLABORATOR_ROLE, journal: @journal, participates_in: [Paper]) do |role|
      role.ensure_permission_exists(:submit, applies_to: Paper)
      role.ensure_permission_exists(:view, applies_to: Paper)
      role.ensure_permission_exists(:edit_authors, applies_to: Paper)
      role.ensure_permission_exists(:view_recent_activity, applies_to: Paper)

      # Collaborators can view and edit any metadata card except billing
      task_klasses = Task.submission_task_types
      task_klasses -= [PlosBilling::BillingTask]
      task_klasses << AdHocForAuthorsTask
      task_klasses.each do |klass|
        role.ensure_permission_exists(:edit, applies_to: klass, states: Paper::EDITABLE_STATES)
        role.ensure_permission_exists(:manage_participant, applies_to: klass)
        role.ensure_permission_exists(:view, applies_to: klass)
        role.ensure_permission_exists(:view_participants, applies_to: klass)
      end
      role.ensure_permission_exists(:view, applies_to: CardVersion)
    end

    Role.ensure_exists(Role::COVER_EDITOR_ROLE, journal: @journal, participates_in: [Paper]) do |role|
      # Paper
      role.ensure_permission_exists(:assign_roles, applies_to: Paper)
      role.ensure_permission_exists(:edit, applies_to: Paper)
      role.ensure_permission_exists(:edit_authors, applies_to: Paper, states: Paper::EDITABLE_STATES)
      role.ensure_permission_exists(:edit_related_articles, applies_to: Paper)
      role.ensure_permission_exists(:manage_collaborators, applies_to: Paper)
      role.ensure_permission_exists(:manage_workflow, applies_to: Paper)
      role.ensure_permission_exists(:perform_similarity_check, applies_to: Paper)
      role.ensure_permission_exists(:register_decision, applies_to: Paper)
      role.ensure_permission_exists(:search_academic_editors, applies_to: Paper)
      role.ensure_permission_exists(:search_admins, applies_to: Paper)
      role.ensure_permission_exists(:search_reviewers, applies_to: Paper)
      role.ensure_permission_exists(:submit, applies_to: Paper)
      role.ensure_permission_exists(:view, applies_to: Paper)
      role.ensure_permission_exists(:view_decisions, applies_to: Paper)
      role.ensure_permission_exists(:view_user_role_eligibility_on_paper, applies_to: Paper)
      role.ensure_permission_exists(:view_recent_activity, applies_to: Paper)

      # Tasks
      task_klasses = Task.descendants

      # Cover editors cannot view, edit, or otherwise do anything on the
      # BillingTask, the ChangesForAuthorTask, or the PaperEditorTask
      task_klasses -= [
        PlosBilling::BillingTask,
        PlosBioTechCheck::ChangesForAuthorTask,
        TahiStandardTasks::PaperEditorTask
      ]
      task_klasses.each do |klass|
        role.ensure_permission_exists(:add_email_participants, applies_to: klass)
        role.ensure_permission_exists(:manage, applies_to: klass)
        role.ensure_permission_exists(:manage_invitations, applies_to: klass)
        role.ensure_permission_exists(:manage_participant, applies_to: klass)
        role.ensure_permission_exists(:view_discussion_footer, applies_to: klass)
        role.ensure_permission_exists(:view, applies_to: klass)
        role.ensure_permission_exists(:view_participants, applies_to: klass)
      end

      # Cover Editors can edit _all_ tasks except for ReviewerReportTask(s).
      # Of those editable tasks all but the TitleAndAstractTask can only be
      # modified if the Paper itself is editable.
      editable_task_klasses = task_klasses -
        [TahiStandardTasks::ReviewerReportTask] -
        TahiStandardTasks::ReviewerReportTask.descendants -
        [TahiStandardTasks::TitleAndAbstractTask]
      editable_task_klasses.each do |klass|
        role.ensure_permission_exists(
          :edit,
          applies_to: klass,
          states: Paper::EDITABLE_STATES
        )
      end

      # The TitleAndAbstractTask is always editable, regardless of paper state.
      role.ensure_permission_exists(:edit, applies_to: TahiStandardTasks::TitleAndAbstractTask)

      # Discussions
      role.ensure_permission_exists(:edit, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:manage_participant, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:reply, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:start_discussion, applies_to: Paper)
      role.ensure_permission_exists(:view, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:view, applies_to: CardVersion)
    end

    Role.ensure_exists(Role::REVIEWER_ROLE, journal: @journal, participates_in: [Paper]) do |role|
      role.ensure_permission_exists(:view, applies_to: Paper)

      # Reviewer(s) get access to all submission tasks, except a few
      task_klasses = Task.submission_task_types
      task_klasses -= [
        PlosBilling::BillingTask,
        TahiStandardTasks::CoverLetterTask,
        TahiStandardTasks::ReviewerRecommendationsTask
      ]
      task_klasses << AdHocForReviewersTask
      task_klasses.each do |klass|
        role.ensure_permission_exists(:view, applies_to: klass.name)
        role.ensure_permission_exists(:view_participants, applies_to: klass.name)
      end
      role.ensure_permission_exists(:edit, applies_to: AdHocForReviewersTask.name, states: Paper::REVIEWABLE_STATES)
      role.ensure_permission_exists(:view, applies_to: CardVersion)
    end

    # This role exists to give a reviewer the ability to edit their reviewer
    # report.
    Role.ensure_exists(Role::REVIEWER_REPORT_OWNER_ROLE, journal: @journal, participates_in: [Task]) do |role|
      role.ensure_permission_exists(
        :edit,
        applies_to: TahiStandardTasks::ReviewerReportTask,
        states: Paper::REVIEWABLE_STATES
      )

      role.ensure_permission_exists(:view, applies_to: TahiStandardTasks::ReviewerReportTask)
      role.ensure_permission_exists(:view, applies_to: CardVersion)
    end

    Role.ensure_exists(Role::JOURNAL_SETUP_ROLE, journal: @journal) do |role|
      role.ensure_permission_exists(:create_card, applies_to: Journal)
      role.ensure_permission_exists(:edit, applies_to: Card)
      role.ensure_permission_exists(:view, applies_to: CardVersion)
    end

    Role.ensure_exists(Role::STAFF_ADMIN_ROLE, journal: @journal) do |role|
      # Journal
      role.ensure_permission_exists(:administer, applies_to: Journal)
      role.ensure_permission_exists(:view_paper_tracker, applies_to: Journal)
      role.ensure_permission_exists(:remove_orcid, applies_to: Journal)

      # Paper
      role.ensure_permission_exists(:assign_roles, applies_to: Paper)
      role.ensure_permission_exists(:edit, applies_to: Paper)
      role.ensure_permission_exists(:edit_authors, applies_to: Paper)
      role.ensure_permission_exists(:edit_related_articles, applies_to: Paper)
      role.ensure_permission_exists(:manage_collaborators, applies_to: Paper)
      role.ensure_permission_exists(:manage_workflow, applies_to: Paper)
      role.ensure_permission_exists(:perform_similarity_check, applies_to: Paper)
      role.ensure_permission_exists(:reactivate, applies_to: Paper, states: ['withdrawn'])
      role.ensure_permission_exists(:register_decision, applies_to: Paper)
      role.ensure_permission_exists(:rescind_decision, applies_to: Paper)
      role.ensure_permission_exists(:send_to_apex, applies_to: Paper)
      role.ensure_permission_exists(:search_academic_editors, applies_to: Paper)
      role.ensure_permission_exists(:search_admins, applies_to: Paper)
      role.ensure_permission_exists(:search_reviewers, applies_to: Paper)
      role.ensure_permission_exists(:submit, applies_to: Paper)
      role.ensure_permission_exists(:view, applies_to: Paper)
      role.ensure_permission_exists(:view_decisions, applies_to: Paper)
      role.ensure_permission_exists(:view_user_role_eligibility_on_paper, applies_to: Paper)
      role.ensure_permission_exists(:withdraw, applies_to: Paper)
      role.ensure_permission_exists(:view_recent_activity, applies_to: Paper)

      # Tasks
      task_klasses = Task.descendants
      task_klasses -= [PlosBilling::BillingTask]
      task_klasses.each do |klass|
        role.ensure_permission_exists(:add_email_participants, applies_to: klass)
        role.ensure_permission_exists(:edit, applies_to: klass)
        role.ensure_permission_exists(:manage, applies_to: klass)
        role.ensure_permission_exists(:manage_invitations, applies_to: klass)
        role.ensure_permission_exists(:manage_participant, applies_to: klass)
        role.ensure_permission_exists(:view_discussion_footer, applies_to: klass)
        role.ensure_permission_exists(:edit_discussion_footer, applies_to: klass)
        role.ensure_permission_exists(:view, applies_to: klass)
        role.ensure_permission_exists(:view_participants, applies_to: klass)
      end

      role.ensure_permission_exists(:view, applies_to: Card)

      # Discussions
      role.ensure_permission_exists(:be_at_mentioned, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:edit, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:manage_participant, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:reply, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:start_discussion, applies_to: Paper)
      role.ensure_permission_exists(:view, applies_to: DiscussionTopic)

      # Users
      role.ensure_permission_exists(:manage_users, applies_to: Journal)
      role.ensure_permission_exists(:view, applies_to: CardVersion)
    end

    Role.ensure_exists(Role::INTERNAL_EDITOR_ROLE, journal: @journal) do |role|
      # Journal
      role.ensure_permission_exists(:view_paper_tracker, applies_to: Journal)

      # Paper
      role.ensure_permission_exists(:assign_roles, applies_to: Paper)
      role.ensure_permission_exists(:edit, applies_to: Paper)
      role.ensure_permission_exists(:edit_authors, applies_to: Paper)
      role.ensure_permission_exists(:edit_related_articles, applies_to: Paper)
      role.ensure_permission_exists(:manage_collaborators, applies_to: Paper)
      role.ensure_permission_exists(:manage_workflow, applies_to: Paper)
      role.ensure_permission_exists(:perform_similarity_check, applies_to: Paper)
      role.ensure_permission_exists(:reactivate, applies_to: Paper, states: ['withdrawn'])
      role.ensure_permission_exists(:register_decision, applies_to: Paper)
      role.ensure_permission_exists(:rescind_decision, applies_to: Paper)
      role.ensure_permission_exists(:search_academic_editors, applies_to: Paper)
      role.ensure_permission_exists(:search_admins, applies_to: Paper)
      role.ensure_permission_exists(:search_reviewers, applies_to: Paper)
      role.ensure_permission_exists(:send_to_apex, applies_to: Paper)
      role.ensure_permission_exists(:submit, applies_to: Paper)
      role.ensure_permission_exists(:view, applies_to: Paper)
      role.ensure_permission_exists(:view_decisions, applies_to: Paper)
      role.ensure_permission_exists(:view_user_role_eligibility_on_paper, applies_to: Paper)
      role.ensure_permission_exists(:withdraw, applies_to: Paper)
      role.ensure_permission_exists(:view_recent_activity, applies_to: Paper)

      # Tasks
      task_klasses = Task.descendants
      task_klasses -= [PlosBilling::BillingTask]
      task_klasses.each do |klass|
        role.ensure_permission_exists(:add_email_participants, applies_to: klass)
        role.ensure_permission_exists(:edit, applies_to: klass)
        role.ensure_permission_exists(:manage, applies_to: klass)
        role.ensure_permission_exists(:manage_invitations, applies_to: klass)
        role.ensure_permission_exists(:manage_participant, applies_to: klass)
        role.ensure_permission_exists(:view_discussion_footer, applies_to: klass)
        role.ensure_permission_exists(:edit_discussion_footer, applies_to: klass)
        role.ensure_permission_exists(:view, applies_to: klass)
        role.ensure_permission_exists(:view_participants, applies_to: klass)
      end

      # Discussions
      role.ensure_permission_exists(:be_at_mentioned, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:edit, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:manage_participant, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:reply, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:start_discussion, applies_to: Paper)
      role.ensure_permission_exists(:view, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:view, applies_to: CardVersion)
    end

    Role.ensure_exists(Role::HANDLING_EDITOR_ROLE, journal: @journal, participates_in: [Paper]) do |role|
      # Paper
      role.ensure_permission_exists(:assign_roles, applies_to: Paper)
      role.ensure_permission_exists(:edit, applies_to: Paper, states: Paper::EDITABLE_STATES)
      role.ensure_permission_exists(:edit_authors, applies_to: Paper, states: Paper::EDITABLE_STATES)
      role.ensure_permission_exists(:edit_related_articles, applies_to: Paper)
      role.ensure_permission_exists(:manage_collaborators, applies_to: Paper)
      role.ensure_permission_exists(:manage_workflow, applies_to: Paper)
      role.ensure_permission_exists(:perform_similarity_check, applies_to: Paper)
      role.ensure_permission_exists(:register_decision, applies_to: Paper)
      role.ensure_permission_exists(:rescind_decision, applies_to: Paper)
      role.ensure_permission_exists(:search_academic_editors, applies_to: Paper)
      role.ensure_permission_exists(:search_admins, applies_to: Paper)
      role.ensure_permission_exists(:search_reviewers, applies_to: Paper)
      role.ensure_permission_exists(:submit, applies_to: Paper)
      role.ensure_permission_exists(:view, applies_to: Paper)
      role.ensure_permission_exists(:view_decisions, applies_to: Paper)
      role.ensure_permission_exists(:view_user_role_eligibility_on_paper, applies_to: Paper)
      role.ensure_permission_exists(:view_recent_activity, applies_to: Paper)

      # Tasks
      task_klasses = Task.descendants

      # Handling editors cannot view, edit, or otherwise do anything on the
      # BillingTask, the ChangesForAuthorTask, or the PaperEditorTast
      task_klasses -= [
        PlosBilling::BillingTask,
        PlosBioTechCheck::ChangesForAuthorTask,
        TahiStandardTasks::PaperEditorTask
      ]
      task_klasses.each do |klass|
        role.ensure_permission_exists(:add_email_participants, applies_to: klass)
        role.ensure_permission_exists(:manage, applies_to: klass)
        role.ensure_permission_exists(:manage_invitations, applies_to: klass)
        role.ensure_permission_exists(:manage_participant, applies_to: klass)
        role.ensure_permission_exists(:view_discussion_footer, applies_to: klass)
        role.ensure_permission_exists(:view, applies_to: klass)
        role.ensure_permission_exists(:view_participants, applies_to: klass)
      end

      # Handling Editors can edit _all_ tasks except for ReviewerReportTask(s).
      # Of those editable tasks all but the TitleAndAstractTask can only be
      # modified if the Paper itself is editable.
      editable_task_klasses = task_klasses -
        [TahiStandardTasks::ReviewerReportTask] -
        TahiStandardTasks::ReviewerReportTask.descendants -
        [TahiStandardTasks::TitleAndAbstractTask]
      editable_task_klasses.each do |klass|
        role.ensure_permission_exists(
          :edit,
          applies_to: klass,
          states: Paper::EDITABLE_STATES
        )
      end

      # The TitleAndAbstractTask is always editable, regardless of paper state.
      role.ensure_permission_exists(:edit, applies_to: TahiStandardTasks::TitleAndAbstractTask)

      # Discussions
      role.ensure_permission_exists(:edit, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:manage_participant, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:reply, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:start_discussion, applies_to: Paper)
      role.ensure_permission_exists(:view, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:be_at_mentioned, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:view, applies_to: CardVersion)
    end

    Role.ensure_exists(Role::PRODUCTION_STAFF_ROLE, journal: @journal) do |role|
      # Journal
      role.ensure_permission_exists(:view_paper_tracker, applies_to: Journal)
      role.ensure_permission_exists(:remove_orcid, applies_to: Journal)

      # Paper
      role.ensure_permission_exists(:assign_roles, applies_to: Paper)
      role.ensure_permission_exists(:edit, applies_to: Paper)
      role.ensure_permission_exists(:edit_authors, applies_to: Paper)
      role.ensure_permission_exists(:edit_related_articles, applies_to: Paper)
      role.ensure_permission_exists(:manage_collaborators, applies_to: Paper)
      role.ensure_permission_exists(:manage_workflow, applies_to: Paper)
      role.ensure_permission_exists(:perform_similarity_check, applies_to: Paper)
      role.ensure_permission_exists(:reactivate, applies_to: Paper, states: ['withdrawn'])
      role.ensure_permission_exists(:register_decision, applies_to: Paper)
      role.ensure_permission_exists(:rescind_decision, applies_to: Paper)
      role.ensure_permission_exists(:search_academic_editors, applies_to: Paper)
      role.ensure_permission_exists(:search_admins, applies_to: Paper)
      role.ensure_permission_exists(:search_reviewers, applies_to: Paper)
      role.ensure_permission_exists(:send_to_apex, applies_to: Paper)
      role.ensure_permission_exists(:submit, applies_to: Paper)
      role.ensure_permission_exists(:view, applies_to: Paper)
      role.ensure_permission_exists(:view_decisions, applies_to: Paper)
      role.ensure_permission_exists(:view_user_role_eligibility_on_paper, applies_to: Paper)
      role.ensure_permission_exists(:withdraw, applies_to: Paper)
      role.ensure_permission_exists(:view_recent_activity, applies_to: Paper)

      # Tasks
      task_klasses = Task.descendants
      task_klasses -= [PlosBilling::BillingTask]
      task_klasses.each do |klass|
        role.ensure_permission_exists(:add_email_participants, applies_to: klass)
        role.ensure_permission_exists(:edit, applies_to: klass)
        role.ensure_permission_exists(:manage, applies_to: klass)
        role.ensure_permission_exists(:manage_invitations, applies_to: klass)
        role.ensure_permission_exists(:manage_participant, applies_to: klass)
        role.ensure_permission_exists(:view_discussion_footer, applies_to: klass)
        role.ensure_permission_exists(:edit_discussion_footer, applies_to: klass)
        role.ensure_permission_exists(:view, applies_to: klass)
        role.ensure_permission_exists(:view_participants, applies_to: klass)
      end

      # Discussions
      role.ensure_permission_exists(:be_at_mentioned, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:edit, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:manage_participant, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:reply, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:start_discussion, applies_to: Paper)
      role.ensure_permission_exists(:view, applies_to: DiscussionTopic)

      # Users
      role.ensure_permission_exists(:manage_users, applies_to: Journal)
      role.ensure_permission_exists(:view, applies_to: CardVersion)
    end

    Role.ensure_exists(Role::PUBLISHING_SERVICES_ROLE, journal: @journal) do |role|
      # Journals
      role.ensure_permission_exists(:view_paper_tracker, applies_to: Journal)
      role.ensure_permission_exists(:remove_orcid, applies_to: Journal)

      # Paper
      role.ensure_permission_exists(:assign_roles, applies_to: Paper)
      role.ensure_permission_exists(:edit, applies_to: Paper)
      role.ensure_permission_exists(:edit_authors, applies_to: Paper)
      role.ensure_permission_exists(:edit_related_articles, applies_to: Paper)
      role.ensure_permission_exists(:manage_collaborators, applies_to: Paper)
      role.ensure_permission_exists(:manage_workflow, applies_to: Paper)
      role.ensure_permission_exists(:perform_similarity_check, applies_to: Paper)
      role.ensure_permission_exists(:reactivate, applies_to: Paper, states: ['withdrawn'])
      role.ensure_permission_exists(:register_decision, applies_to: Paper)
      role.ensure_permission_exists(:rescind_decision, applies_to: Paper)
      role.ensure_permission_exists(:search_academic_editors, applies_to: Paper)
      role.ensure_permission_exists(:search_admins, applies_to: Paper)
      role.ensure_permission_exists(:search_reviewers, applies_to: Paper)
      role.ensure_permission_exists(:send_to_apex, applies_to: Paper)
      role.ensure_permission_exists(:submit, applies_to: Paper)
      role.ensure_permission_exists(:view, applies_to: Paper)
      role.ensure_permission_exists(:view_decisions, applies_to: Paper)
      role.ensure_permission_exists(:view_user_role_eligibility_on_paper, applies_to: Paper)
      role.ensure_permission_exists(:withdraw, applies_to: Paper)
      role.ensure_permission_exists(:view_recent_activity, applies_to: Paper)

      # Tasks
      task_klasses = Task.descendants
      task_klasses -= [PlosBilling::BillingTask]
      task_klasses.each do |klass|
        role.ensure_permission_exists(:add_email_participants, applies_to: klass)
        role.ensure_permission_exists(:edit, applies_to: klass)
        role.ensure_permission_exists(:manage, applies_to: klass)
        role.ensure_permission_exists(:manage_invitations, applies_to: klass)
        role.ensure_permission_exists(:manage_participant, applies_to: klass)
        role.ensure_permission_exists(:view_discussion_footer, applies_to: klass)
        role.ensure_permission_exists(:edit_discussion_footer, applies_to: klass)
        role.ensure_permission_exists(:view, applies_to: klass)
        role.ensure_permission_exists(:view_participants, applies_to: klass)
      end

      # Discussions
      role.ensure_permission_exists(:be_at_mentioned, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:edit, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:manage_participant, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:start_discussion, applies_to: Paper)
      role.ensure_permission_exists(:reply, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:view, applies_to: DiscussionTopic)

      # Users
      role.ensure_permission_exists(:manage_users, applies_to: Journal)
      role.ensure_permission_exists(:view, applies_to: CardVersion)
    end

    Role.ensure_exists(Role::TASK_PARTICIPANT_ROLE, journal: @journal, participates_in: [Task]) do |role|
      role.ensure_permission_exists(:view, applies_to: Paper)

      role.ensure_permission_exists(:edit, applies_to: Task, states: Paper::EDITABLE_STATES)
      role.ensure_permission_exists(:manage_participant, applies_to: Task)
      role.ensure_permission_exists(:view, applies_to: Task)
      role.ensure_permission_exists(:view_participants, applies_to: Task)
      role.ensure_permission_exists(:view, applies_to: CardVersion)
    end

    Role.ensure_exists(Role::ACADEMIC_EDITOR_ROLE,
                       journal: @journal,
                       participates_in: [Paper]) do |role|
      role.ensure_permission_exists(:view, applies_to: Paper)

      task_klasses = Task.submission_task_types

      # AEs cannot view Billing task, Register Decision tasks, or
      # Changes For Author tasks. However, AEs can view all
      # ReviewerReportTask(s) and its descendants, but cannot edit them.
      task_klasses -= [
        PlosBilling::BillingTask,
        PlosBioTechCheck::ChangesForAuthorTask,
        TahiStandardTasks::RegisterDecisionTask
      ]
      task_klasses << TahiStandardTasks::ReviewerReportTask
      task_klasses.each do |klass|
        role.ensure_permission_exists(:view, applies_to: klass)
      end

      AdHocForEditorsTask.tap do |klass|
        role.ensure_permission_exists(:edit, applies_to: klass)
        role.ensure_permission_exists(:view, applies_to: klass)
      end
    end

    Role.ensure_exists(Role::DISCUSSION_PARTICIPANT, journal: @journal) do |role|
      role.ensure_permission_exists(:be_at_mentioned, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:reply, applies_to: DiscussionTopic)
      role.ensure_permission_exists(:view, applies_to: DiscussionTopic)
    end

    Role.ensure_exists(Role::FREELANCE_EDITOR_ROLE, journal: @journal)

    Role.ensure_exists(Role::BILLING_ROLE, journal: @journal, participates_in: [Task]) do |role|
      task_klasses = Task.descendants
      task_klasses.each do |klass|
        role.ensure_permission_exists(:view_discussion_footer, applies_to: klass)
        role.ensure_permission_exists(:view, applies_to: klass)
        role.ensure_permission_exists(:view_participants, applies_to: klass)
      end

      role.ensure_permission_exists(:edit, applies_to: PlosBilling::BillingTask)
      role.ensure_permission_exists(:view_paper_tracker, applies_to: Journal)
      role.ensure_permission_exists(:view, applies_to: Paper)
      role.ensure_permission_exists(:view, applies_to: CardVersion)
      role.ensure_permission_exists(:view_recent_activity, applies_to: Paper)
    end
  end
end
