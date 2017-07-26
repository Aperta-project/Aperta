class AddAutomaticToSimilarityCheck < ActiveRecord::Migration
  def change
    add_column :similarity_checks, :automatic, :boolean, null: false, default: false
  end
end
