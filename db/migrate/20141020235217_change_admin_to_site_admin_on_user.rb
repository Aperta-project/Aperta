class ChangeAdminToSiteAdminOnUser < ActiveRecord::Migration
  def change
    remove_column :users, :admin, :boolean, default: false
    add_column    :users, :site_admin, :boolean, default: false
  end
end
