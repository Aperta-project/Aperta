class AddErrorMessageToSimilarityCheck < ActiveRecord::Migration
  def change
    add_column :similarity_checks, :error_message, :string
  end
end
