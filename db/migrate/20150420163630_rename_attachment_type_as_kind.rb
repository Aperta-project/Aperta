class RenameAttachmentTypeAsKind < ActiveRecord::Migration
  def change
    rename_column :attachments, :attachment_type, :kind
  end
end
