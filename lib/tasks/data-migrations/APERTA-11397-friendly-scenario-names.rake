namespace :data do
  namespace :migrate do
    desc <<-DESC
      Change the references to scenarios to friendlier names.
    DESC
    task setup_friendly_scenario_names: :environment do
      # This list of scenarios is the same as TemplateContext.scenarios as at
      # APERTA-11397. TemplateContext.scenarios may change, that's why this list
      # is duplicated here.
      scenarios = {
        'PaperScenario'            => 'Manuscript',
        'ReviewerReportScenario'   => 'Reviewer Report',
        'InvitationScenario'       => 'Invitation',
        'PaperReviewerScenario'    => 'Paper Reviewer',
        'PreprintDecisionScenario' => 'Preprint Decision',
        'RegisterDecisionScenario' => 'Decision',
        'TechCheckScenario'        => 'Tech Check'
      }

      # Remove module scopes
      # rubocop:disable Rails/SkipsModelValidations
      LetterTemplate
        .where(scenario: 'TahiStandardTasks::RegisterDecisionScenario')
        .update_all(scenario: 'RegisterDecisionScenario')
      LetterTemplate
        .where(scenario: 'TahiStandardTasks::PreprintDecisionScenario')
        .update_all(scenario: 'PreprintDecisionScenario')
      LetterTemplate
        .where(scenario: 'TahiStandardTasks::PaperReviewerScenario')
        .update_all(scenario: 'PaperReviewerScenario')
      # rubocop:enable Rails/SkipsModelValidations

      LetterTemplate.find_each do |tpl|
        scenario_class = tpl.scenario
        if scenario_class == 'SendbacksContext'
          tpl.update(scenario: 'Tech Check')
          next
        end

        tpl.update(scenario: scenarios[scenario_class]) if scenarios.key? scenario_class
      end
    end
  end
end
