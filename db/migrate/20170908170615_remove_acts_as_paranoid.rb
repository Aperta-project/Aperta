class RemoveActsAsParanoid < ActiveRecord::Migration
  def change
    remove_column :answers, :deleted_at
    remove_column :card_content_validations, :deleted_at
    remove_column :card_contents, :deleted_at
    remove_column :card_versions, :deleted_at
    remove_column :cards, :deleted_at
  end
end
