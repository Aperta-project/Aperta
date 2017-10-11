class AddPositionToRepetitions < ActiveRecord::Migration
  def change
    add_column :repetitions, :position, :integer, null: false, default: 0
  end
end
