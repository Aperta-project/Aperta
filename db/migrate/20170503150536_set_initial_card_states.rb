class SetInitialCardStates < DataMigration
  RAKE_TASK_UP = 'data:migrate:cards:set_initial_states'.freeze
  RAKE_TASK_DOWN = 'data:migrate:cards:unset_initial_states'.freeze
end
