class AddDefaultAnswerValueToCardContents < ActiveRecord::Migration
  def change
    add_column :card_contents, :default_answer_value, :string
  end
end
