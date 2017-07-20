class CreateRegisteredSettings < ActiveRecord::Migration
  def change
    create_table :registered_settings do |t|
      t.string :key
      t.string :setting_klass
      t.string :setting_name
      t.boolean :global
      t.references :journal
    end
    add_index :registered_settings, :key
  end
end
