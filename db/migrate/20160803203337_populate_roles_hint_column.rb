# Runs the migration to populate the hint column.
class PopulateRolesHintColumn < DataMigration
  RAKE_TASK_UP = 'data:migrate:roles:add_assigned_to_hints'
end
