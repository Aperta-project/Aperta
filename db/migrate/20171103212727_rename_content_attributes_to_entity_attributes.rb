class RenameContentAttributesToEntityAttributes < ActiveRecord::Migration
  def change
    rename_table :content_attributes, :entity_attributes
  end
end
