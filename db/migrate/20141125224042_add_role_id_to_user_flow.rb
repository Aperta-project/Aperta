class AddRoleIdToUserFlow < ActiveRecord::Migration
  def change
    add_column :user_flows, :role_id, :integer
  end
end
