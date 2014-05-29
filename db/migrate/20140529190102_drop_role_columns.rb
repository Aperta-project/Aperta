class DropRoleColumns < ActiveRecord::Migration
  def change
    remove_column :roles, :admin, :boolean
    remove_column :roles, :reviewer, :boolean
    remove_column :roles, :editor, :boolean
  end
end
