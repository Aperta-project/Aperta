class MapOldQueriesToNewFlowQueries < ActiveRecord::Migration
  def up
    Flow.where("role_id IS NOT ?", nil).destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
