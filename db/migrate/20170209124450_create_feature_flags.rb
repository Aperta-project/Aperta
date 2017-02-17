# A minimal table to replace environment-variable based feature flags
class CreateFeatureFlags < ActiveRecord::Migration
  def change
    create_table :feature_flags, id: false do |t|
      t.string :name, null: false, unique: true
      t.boolean :active, null: false
    end
  end
end
