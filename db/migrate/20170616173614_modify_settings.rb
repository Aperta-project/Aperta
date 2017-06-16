# Add explicit value types to the settings table rather than having to rely
# on casting from a string
class ModifySettings < ActiveRecord::Migration
  def change
    add_column :settings, :value_type, :string, null: false, default: "string"
    add_column :settings, :integer_value, :integer
    add_column :settings, :boolean_value, :boolean
    rename_column :settings, :value, :string_value
  end
end
