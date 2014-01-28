class AddLogoToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :logo, :string
  end
end
