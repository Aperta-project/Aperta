class MapOldQueriesToNewFlowQueries < ActiveRecord::Migration
  def up
    execute <<-SQL
      DELETE FROM flows WHERE flows.role_id IS NOT null;
    SQL
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
