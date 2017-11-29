class RenameEventBehaviorsToBehaviors < ActiveRecord::Migration
  def change
    rename_table :event_behaviors, :behaviors
  end
end
