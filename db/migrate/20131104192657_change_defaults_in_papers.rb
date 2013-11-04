class ChangeDefaultsInPapers < ActiveRecord::Migration
  def up
    change_column_default :papers, :abstract, ''
    change_column_default :papers, :body, ''
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
