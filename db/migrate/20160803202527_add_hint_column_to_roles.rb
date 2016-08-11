class AddHintColumnToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :assigned_to_type_hint, :string
    add_index :roles, :assigned_to_type_hint
  end
end
