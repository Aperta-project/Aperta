# This migration removes the users.site_admin column from the
# database as it is no longer necessary at this point.
class RemoveSiteAdminFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :site_admin, :boolean, default: false
  end
end
