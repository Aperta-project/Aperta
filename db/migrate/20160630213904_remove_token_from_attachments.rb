# Removes token column from Attachments. This should have been removed with
# db/migrate/20160622174329_add_resource_token.rb but was overlooked.
class RemoveTokenFromAttachments < ActiveRecord::Migration
  def change
    remove_column :attachments, :token, :string
  end
end
