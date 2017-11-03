class RemoveModuleScopeFromRegisterDecisionScenario < ActiveRecord::Migration
  def change
    LetterTemplate
      .where(scenario: 'TahiStandardTasks::RegisterDecisionScenario')
      .update_all(scenario: 'RegisterDecisionScenario')
  end
end
