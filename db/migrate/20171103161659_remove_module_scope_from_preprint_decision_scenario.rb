class RemoveModuleScopeFromPreprintDecisionScenario < ActiveRecord::Migration
  def change
    LetterTemplate
      .where(scenario: 'TahiStandardTasks::PreprintDecisionScenario')
      .update_all(scenario: 'PreprintDecisionScenario')
  end
end
