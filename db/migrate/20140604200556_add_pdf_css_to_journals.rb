class AddPdfCssToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :pdf_css, :text
  end
end
