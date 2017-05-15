class AddPdfAllowedColumnToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :pdf_allowed, :boolean, default: false
  end
end
