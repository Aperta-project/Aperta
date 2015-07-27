class AddRinggoldIdToPlosAuthors < ActiveRecord::Migration
  def change
    add_column :plos_authors_plos_authors, :ringgold_id, :string
    add_column :plos_authors_plos_authors, :secondary_ringgold_id, :string
  end
end
