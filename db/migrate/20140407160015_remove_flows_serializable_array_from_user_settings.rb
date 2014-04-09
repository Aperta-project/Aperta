class RemoveFlowsSerializableArrayFromUserSettings < ActiveRecord::Migration
  def change
    remove_column :user_settings, :flows
  end
end
