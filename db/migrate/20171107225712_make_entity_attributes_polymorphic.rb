class MakeEntityAttributesPolymorphic < ActiveRecord::Migration
  def up
    add_column :entity_attributes, :entity_type, :string
    execute "UPDATE entity_attributes SET entity_type = 'CardContent';"
    change_column_null :entity_attributes, :entity_type, false
    rename_column :entity_attributes, :card_content_id, :entity_id
  end

  def down
    rename_column :entity_attributes, :entity_id, :card_content_id
    remove_column :entity_attributes, :entity_type
  end
end
