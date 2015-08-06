class RemoveUnneededVersionedTextColumns < ActiveRecord::Migration
  def change
    remove_column :versioned_texts, :active
    remove_column :versioned_texts, :copy_on_edit
  end
end
