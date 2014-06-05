class AddEpubCssToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :epub_css, :text
  end
end
