class AddPositionToPhaseTemplates < ActiveRecord::Migration
  def change
    add_column :phase_templates, :position, :integer
  end
end
