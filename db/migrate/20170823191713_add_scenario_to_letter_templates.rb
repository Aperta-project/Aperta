class AddScenarioToLetterTemplates < ActiveRecord::Migration
  def change
    add_column :letter_templates, :scenario, :string
    # rubocop:disable Rails/SkipsModelValidations
    LetterTemplate.update_all scenario: 'TahiStandardTasks::RegisterDecisionScenario'
  end
end
