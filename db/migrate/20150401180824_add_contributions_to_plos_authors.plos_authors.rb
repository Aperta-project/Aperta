# This migration comes from plos_authors (originally 20150401180553)
class AddContributionsToPlosAuthors < ActiveRecord::Migration
  def change
    add_column :plos_authors_plos_authors, :contributions, :string
  end
end
