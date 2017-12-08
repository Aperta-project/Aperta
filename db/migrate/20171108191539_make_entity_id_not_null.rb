class MakeEntityIdNotNull < ActiveRecord::Migration
  def change
    change_column_null :entity_attributes, :entity_id, false
    change_column_null :entity_attributes, :name, false
    change_column_null :entity_attributes, :value_type, false
  end
end
