# This data migration ensures that invitations that were associated with tasks
# are properly associated into queues
class MigrateInvitationsToQueues < DataMigration
  RAKE_TASK_UP = 'data:migrate:migrate_invitations_to_queues'.freeze
  RAKE_TASK_DOWN = 'data:migrate:migrate_queues_back_to_invitations'.freeze
end
