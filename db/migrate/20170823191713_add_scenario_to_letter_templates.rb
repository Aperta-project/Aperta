class AddScenarioToLetterTemplates < ActiveRecord::Migration
  def change
    add_column :letter_templates, :scenario, :string
  end
end
