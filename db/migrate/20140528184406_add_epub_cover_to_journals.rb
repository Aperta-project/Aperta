class AddEpubCoverToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :epub_cover, :string
  end
end
