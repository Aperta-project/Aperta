class AddAttachmentTypeToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :attachment_type, :string
  end
end
