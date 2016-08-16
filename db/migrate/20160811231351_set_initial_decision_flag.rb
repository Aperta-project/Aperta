# Initialize the 'initial' flag on Decisions
class SetInitialDecisionFlag < DataMigration
  RAKE_TASK_UP = 'data:migrate:decisions:set_initial_decision'
end
