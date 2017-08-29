class AddClassAndElementAttributesToCardContent < ActiveRecord::Migration
  def up
    add_column :card_contents, :child_tag, :string
    add_column :card_contents, :custom_class, :string
    add_column :card_contents, :custom_child_class, :string
    add_column :card_contents, :wrapper_tag, :string
  end

  def down
    remove_column :card_contents, :child_tag
    remove_column :card_contents, :custom_class
    remove_column :card_contents, :custom_child_class
    remove_column :card_contents, :wrapper_tag
  end
end
