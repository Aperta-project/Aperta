class CreatePhaseTemplates < ActiveRecord::Migration
  def change
    create_table :phase_templates do |t|
      t.string :name
      t.references :manuscript_manager_template, index: true
      t.timestamps
    end
  end
end
