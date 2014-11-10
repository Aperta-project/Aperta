class AddCanViewFlowManagerToRole < ActiveRecord::Migration
  def change
    add_column :roles, :can_view_flow_manager, :boolean, default: false, null: false
  end
end
