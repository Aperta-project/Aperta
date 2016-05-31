class UseDefaultFlows < ActiveRecord::Migration
  def up
    # We no longer want any user_flows created before this migration
    # since they are not associted with the default flows.
    # The default flows will be included to the users choices when they
    # visit their flow manager.
    execute <<-SQL
      DELETE FROM user_flows;
      DELETE FROM flows;
    SQL
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
