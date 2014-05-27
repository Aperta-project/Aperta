class AddAffiliationStringsToAuthor < ActiveRecord::Migration
  def change
    add_column :authors, :affiliation, :string
    add_column :authors, :secondary_affiliation, :string
  end
end
