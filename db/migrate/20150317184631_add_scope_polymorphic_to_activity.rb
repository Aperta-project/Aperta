class AddScopePolymorphicToActivity < ActiveRecord::Migration
  def change
    rename_column :activities, :event_scope, :region_name
    rename_column :activities, :event_action, :event_name
    add_column :activities, :scope_type, :string
    add_column :activities, :scope_id, :integer
  end
end
