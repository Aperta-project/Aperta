class UserSettingHasManyFlows < ActiveRecord::Migration
  def change
    add_column :flows, :user_settings_id, :integer
  end
end
