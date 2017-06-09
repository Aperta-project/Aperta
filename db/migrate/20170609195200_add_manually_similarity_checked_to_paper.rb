class AddManuallySimilarityCheckedToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :manually_similarity_checked, :boolean, null: false, default: false
  end
end
