class AddDescriptionToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :description, :text
  end
end
