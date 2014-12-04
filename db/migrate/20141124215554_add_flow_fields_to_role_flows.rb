class AddFlowFieldsToRoleFlows < ActiveRecord::Migration
  def change
    add_column :role_flows, :query, :text
    add_column :role_flows, :default, :boolean, default: false
  end
end
