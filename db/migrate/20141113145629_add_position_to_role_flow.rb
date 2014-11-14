class AddPositionToRoleFlow < ActiveRecord::Migration
  def change
    add_column :role_flows, :position, :integer
  end
end
