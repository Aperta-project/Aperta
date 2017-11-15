class BehaviorRenameActionToType < ActiveRecord::Migration
  def change
    rename_column :behaviors, :action, :type
  end
end
