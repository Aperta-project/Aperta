class ChangeAdminToSiteAdminOnUser < ActiveRecord::Migration
  def change
    rename_column :users, :admin, :site_admin
  end
end
