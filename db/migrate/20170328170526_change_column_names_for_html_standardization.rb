class ChangeColumnNamesForHtmlStandardization < ActiveRecord::Migration
  def change
    rename_column :attachments, :title, :title_html
    rename_column :attachments, :caption, :caption_html
    rename_column :comments, :body, :body_html
    rename_column :decisions, :letter, :letter_html
  end
end
