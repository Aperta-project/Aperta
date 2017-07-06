class CreatePossibleSettingValues < ActiveRecord::Migration
  def change
    create_table :possible_setting_values do |t|
      t.references :setting_template, index: true
      t.string :value_type, null: false, default: "string"
      t.string :string_value
      t.boolean :boolean_value
      t.integer :integer_value
      t.timestamps null: false
    end
  end
end
