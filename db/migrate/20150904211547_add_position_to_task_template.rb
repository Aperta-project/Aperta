class AddPositionToTaskTemplate < ActiveRecord::Migration
  def change
    add_column :task_templates, :position, :integer
  end
end
