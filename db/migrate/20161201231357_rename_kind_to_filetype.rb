class RenameKindToFiletype < ActiveRecord::Migration
  def change
    rename_column :attachments, :kind, :file_type
  end
end
