class AddInstructionTextToCardContents < ActiveRecord::Migration
  def change
    add_column :card_contents, :instruction_text, :string
  end
end
