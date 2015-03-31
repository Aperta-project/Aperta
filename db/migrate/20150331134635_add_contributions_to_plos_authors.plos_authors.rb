# This migration comes from plos_authors (originally 20150331134528)
class AddContributionsToPlosAuthors < ActiveRecord::Migration
  def change
    add_column :plos_authors_plos_authors, :contributions, :string
  end
end
