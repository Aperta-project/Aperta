class AddPossibleValuesToCardContents < ActiveRecord::Migration
  def change
    add_column :card_contents, :possible_values, :jsonb
  end
end
