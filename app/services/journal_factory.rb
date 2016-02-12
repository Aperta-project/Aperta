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

  def initialize(journal)
    @journal = journal
  end

  def create
    @journal.save!
    ensure_default_roles_and_permissions_exist
    @journal
  end

  # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/LineLength
  def ensure_default_roles_and_permissions_exist
    Role.ensure_exists(Role::CREATOR_ROLE, journal: @journal, participates_in: [Task, Paper]) do |role|
      role.ensure_permission_exists(:view, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:edit, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:manage_collaborators, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:view, applies_to: Task, states: ['*'])
      role.ensure_permission_exists(:edit, applies_to: Task, states: ['*'])
      role.ensure_permission_exists(:withdraw, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:view, applies_to: PlosBilling::BillingTask, states: ['*'])
      role.ensure_permission_exists(:edit, applies_to: PlosBilling::BillingTask, states: ['*'])
    end

    Role.ensure_exists(Role::COLLABORATOR_ROLE, journal: @journal, participates_in: [Paper]) do |role|
      role.ensure_permission_exists(:view, applies_to: Paper, states: ['*'])
    end

    Role.ensure_exists(Role::REVIEWER_ROLE, journal: @journal, participates_in: [Paper]) do |role|
      role.ensure_permission_exists(:view, applies_to: Paper, states: ['*'])
    end

    Role.ensure_exists(Role::STAFF_ADMIN_ROLE, journal: @journal) do |role|
      role.ensure_permission_exists(:administer, applies_to: 'Journal', states: ['*'])
      role.ensure_permission_exists(:manage_workflow, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:view, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:edit, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:manage_collaborators, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:view, applies_to: Task, states: ['*'])
      role.ensure_permission_exists(:edit, applies_to: Task, states: ['*'])
      role.ensure_permission_exists(:view, applies_to: PlosBilling::BillingTask, states: ['*'])
      role.ensure_permission_exists(:edit, applies_to: PlosBilling::BillingTask, states: ['*'])
    end

    Role.ensure_exists(Role::INTERNAL_EDITOR_ROLE, journal: @journal) do |role|
      role.ensure_permission_exists(:manage_workflow, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:view, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:edit, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:manage_collaborators, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:view, applies_to: Task, states: ['*'])
      role.ensure_permission_exists(:edit, applies_to: Task, states: ['*'])
    end

    Role.ensure_exists(Role::HANDLING_EDITOR_ROLE, journal: @journal, participates_in: [Paper]) do |role|
      role.ensure_permission_exists(:manage_workflow, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:view, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:edit, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:view, applies_to: Task, states: ['*'])
      role.ensure_permission_exists(:edit, applies_to: Task, states: ['*'])
    end

    Role.ensure_exists(Role::PUBLISHING_SERVICES_ROLE, journal: @journal) do |role|
      role.ensure_permission_exists(:manage_workflow, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:view, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:edit, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:withdraw, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:manage_collaborators, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:view, applies_to: Task, states: ['*'])
      role.ensure_permission_exists(:edit, applies_to: Task, states: ['*'])
      role.ensure_permission_exists(:view, applies_to: PlosBilling::BillingTask, states: ['*'])
      role.ensure_permission_exists(:edit, applies_to: PlosBilling::BillingTask, states: ['*'])
    end

    Role.ensure_exists(Role::PARTICIPANT_ROLE, journal: @journal, participates_in: [Task]) do |role|
      role.ensure_permission_exists(:view, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:manage_collaborators, applies_to: Paper, states: ['*'])
      role.ensure_permission_exists(:view, applies_to: Task, states: ['*'])
      role.ensure_permission_exists(:edit, applies_to: Task, states: ['*'])
    end

    Role.ensure_exists(Role::ACADEMIC_EDITOR_ROLE,
                       journal: @journal,
                       participates_in: [Paper],
                       delete_stray_permissions: true) do |role|
      role.ensure_permission_exists(:view, applies_to: Paper)
      classes = Task.metadata_task_types
      classes -= [PlosBilling::BillingTask]
      classes << TahiStandardTasks::RegisterDecisionTask
      classes.each do |klass|
        role.ensure_permission_exists(:view, applies_to: klass)
        # TODO: Remove this when APERTA-5996 is fixed
        role.ensure_permission_exists(:edit, applies_to: klass)
      end
    end
  end
end
