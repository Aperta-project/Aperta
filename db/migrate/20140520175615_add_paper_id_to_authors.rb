class AddPaperIdToAuthors < ActiveRecord::Migration
  def change
    add_column :authors, :paper_id, :integer
    remove_column :papers, :authors, :string
  end
end
