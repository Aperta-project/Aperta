class AddContributionsToPlosAuthors < ActiveRecord::Migration
  def change
    add_column :plos_authors_plos_authors, :contributions, :string
  end
end
