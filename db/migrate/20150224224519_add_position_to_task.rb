class AddPositionToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :position, :integer, default: 0
  end
end
