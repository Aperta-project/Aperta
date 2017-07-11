class RenameRegisteredSetting < ActiveRecord::Migration
  def change
    rename_table :registered_settings, :setting_templates

    change_table :setting_templates do |t|
      t.string :value_type, null: false, default: "string"
      t.string :string_value
      t.boolean :boolean_value
      t.integer :integer_value
    end
  end
end
