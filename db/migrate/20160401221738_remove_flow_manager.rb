class RemoveFlowManager < ActiveRecord::Migration
  def change
    drop_table :flows
    drop_table :user_flows
    remove_column :old_roles, :can_view_flow_manager
  end
end
