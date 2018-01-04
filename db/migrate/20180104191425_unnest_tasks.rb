# Remove all the old prefixes
class UnnestTasks < ActiveRecord::Migration
  PREFIXES = [
    "TahiStandardTasks::",
    "PlosBioTechCheck::",
    "Tahi::AssignTeam::",
    "PlosBioInternalReview::",
    "PlosBilling::"
  ].freeze

  COLUMNS = [
    { table: 'activities', column: 'subject_type' },
    { table: 'answers', column: 'owner_type' },
    { table: 'assignments', column: 'assigned_to_type' },
    { table: 'card_task_types', column: 'task_class' },
    { table: 'cards', column: 'name' },
    { table: 'email_logs', column: 'additional_context' },
    { table: 'journal_task_types', column: 'kind' },
    { table: 'permissions', column: 'applies_to' },
    { table: 'settings_templates', column: 'key' },
    { table: 'tasks', column: 'type' }
  ].freeze

  def up
    PREFIXES.each do |prefix|
      COLUMNS.each do |table:, column:|
        res = execute("SELECT data_type FROM information_schema.columns WHERE table_name = '#{table}' and column_name = '#{column}';")[0]['data_type']
        coerce = if res == 'jsonb'
                   '::jsonb'
                 else
                   ''
                 end
        execute "UPDATE #{table} SET #{column} = replace(#{column}::text, '#{prefix}', '')#{coerce}"
      end
    end
  end
end
