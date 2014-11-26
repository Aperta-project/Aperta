class AddRoleIdToUserFlow < ActiveRecord::Migration
  def change
    add_column :user_flows, :role_flow_id, :integer
  end
end
