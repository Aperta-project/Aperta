class RemovePdfAllowedFromJournals < ActiveRecord::Migration
  def up
    remove_column :journals, :pdf_allowed
  end

  def down
    add_column :journals, :pdf_allowed, :boolean, default: false
  end
end
