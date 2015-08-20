class RemoveUnneededVersionedTextColumns < ActiveRecord::Migration
  def change
    remove_column :versioned_texts, :active, :boolean, default: true
    remove_column :versioned_texts, :copy_on_edit, :boolean, default: false
  end
end
