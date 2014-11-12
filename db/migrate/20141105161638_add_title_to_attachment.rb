class AddTitleToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :title,   :string
    add_column :attachments, :caption, :string
    add_column :attachments, :status, :string, default: :processing
  end

  def down
    remove_column :attachments, :title
    remove_column :attachments, :caption
    remove_column :attachments, :status
  end
end
