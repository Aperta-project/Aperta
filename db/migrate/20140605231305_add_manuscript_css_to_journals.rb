class AddManuscriptCssToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :manuscript_css, :text
  end
end
