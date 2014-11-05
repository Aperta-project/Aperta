class AddTitleToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :title,   :string
    add_column :attachments, :caption, :string
  end

  def down
    remove_column :attachments, :title
    remove_column :attachments, :caption
  end
end
