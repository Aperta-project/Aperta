class AddIdToFeatureFlags < ActiveRecord::Migration
  def change
    add_column :feature_flags, :id, :primary_key
  end
end
