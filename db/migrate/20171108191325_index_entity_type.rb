class IndexEntityType < ActiveRecord::Migration
  def change
    add_index :entity_attributes, :entity_type
  end
end
