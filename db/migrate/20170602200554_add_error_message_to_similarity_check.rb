class AddErrorMessageToSimilarityCheck < ActiveRecord::Migration
  def change
    add_column :similarity_checks, :error_message, :string
    add_column :similarity_checks, :dismissed, :boolean, default: false
  end
end
