class RenameRoleFlowsToFlows < ActiveRecord::Migration
  def change
    rename_table :role_flows, :flows
    rename_column :user_flows, :role_flow_id, :flow_id
  end
end
