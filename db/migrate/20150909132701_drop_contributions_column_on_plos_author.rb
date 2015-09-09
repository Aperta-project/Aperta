class DropContributionsColumnOnPlosAuthor < ActiveRecord::Migration
  def change
    remove_column :plos_authors_plos_authors, :contributions, :text
  end
end
