class ChangeColumnNamesForHtmlStandardization < ActiveRecord::Migration
  def change
    rename_column :attachments, :title, :title_html
    rename_column :attachments, :caption, :caption_html
  end
end
