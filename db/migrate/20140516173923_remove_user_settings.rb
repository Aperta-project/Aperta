unless defined? Flow
  class Flow < ActiveRecord::Base; end
end

unless defined? UserSettings
  class UserSettings < ActiveRecord::Base
    belongs_to :user
    has_many :flows
  end
end

class RemoveUserSettings < ActiveRecord::Migration
  def up
    add_column :flows, :user_id, :integer, index: true

    Flow.all.each do |flow|
      # this weirdness is due to poor relationships between Flow & UserSetting
      # which is one of the many reasons it is being removed
      user_id = UserSettings.find_by(id: flow.user_settings_id)
      flow.update_column(:user_id, user_id)
    end

    drop_table :user_settings
    remove_column :flows, :user_settings_id
  end

  def down
    remove_column :flows, :user_id
    add_column :flows, :user_settings_id, :integer
    create_table :user_settings do |t|
      t.references :user, index: true
      t.timestamps
    end
  end
end
