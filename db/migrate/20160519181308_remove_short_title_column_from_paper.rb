class RemoveShortTitleColumnFromPaper < ActiveRecord::Migration
  def change
    remove_column :papers, :short_title, :string
  end
end
