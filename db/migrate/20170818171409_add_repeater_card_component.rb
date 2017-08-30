class AddRepeaterCardComponent < ActiveRecord::Migration
  def change
    add_column :card_contents, :initial, :string
    add_column :card_contents, :min, :string
    add_column :card_contents, :max, :string
  end
end
