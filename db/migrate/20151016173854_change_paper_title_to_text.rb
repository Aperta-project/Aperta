class ChangePaperTitleToText < ActiveRecord::Migration
  def change
    change_column :papers, :title, :text
  end
end
