class AddPositionToPhases < ActiveRecord::Migration
  def change
    add_column :phases, :position, :integer
  end
end
