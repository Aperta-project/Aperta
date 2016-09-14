# Keep track of who uploaded an attachment
class AddUploadedByIdToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :uploaded_by_id, :integer
  end
end
