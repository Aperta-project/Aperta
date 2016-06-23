class AddFileHashToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :file_hash, :string
    add_column :attachments, :previous_file_hash, :string
  end
end
