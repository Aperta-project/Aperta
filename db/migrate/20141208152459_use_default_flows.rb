class UseDefaultFlows < ActiveRecord::Migration
  def up
    # We no longer want any user_flows created before this migration
    # since they are not associted with the default flows.
    # The default flows will be included to the users choices when they
    # visit their flow manager.
    UserFlow.destroy_all
    Flow.destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
