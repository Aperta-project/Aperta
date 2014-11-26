class AddIndexKeysForPaperDoi < ActiveRecord::Migration
  def change
    add_index :papers, :doi, unique: true
  end
end
