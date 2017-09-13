class AddIdToFeatureFlags < ActiveRecord::Migration
  def change
    add_column :feature_flags, :id, :primary_key
    add_index :feature_flags, :name, unique: true
  end
end
