# Backfills state dates on previous invitations
class PopulateStateDatesOnInvitations < DataMigration
  RAKE_TASK_UP = 'data:migrate:invitations:populate_dates'.freeze
end
