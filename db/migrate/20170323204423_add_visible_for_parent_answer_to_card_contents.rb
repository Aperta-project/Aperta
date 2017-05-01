class AddVisibleForParentAnswerToCardContents < ActiveRecord::Migration
  def change
    add_column :card_contents, :visible_with_parent_answer, :string
  end
end
