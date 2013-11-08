class AddPaperTypeToPapers < ActiveRecord::Migration
  def up
    add_column :papers, :paper_type, :string

    execute "UPDATE papers SET paper_type = 'research'"
    change_column_null :papers, :paper_type, true
  end

  def down
    remove_column :papers, :paper_type
  end
end
