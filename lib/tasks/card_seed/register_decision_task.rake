# rubocop:disable Metrics/LineLength, Style/StringLiterals

require_relative './support/card_seeder'
namespace 'card_seed' do
  task 'register_decision_task': :environment do
    content = []

    content << {
      ident: "register_decision_questions--selected-template",
      value_type: "text",
      text: "Please select a template."
    }

    content << {
      ident: "register_decision_questions--to-field",
      value_type: "text",
      text: "Enter the email here"
    }

    content << {
      ident: "register_decision_questions--subject-field",
      value_type: "text",
      text: "Enter the subject here"
    }

    CardSeeder.seed_card('TahiStandardTasks::RegisterDecisionTask', content)
  end
end

# rubocop:enable Metrics/LineLength, Style/StringLiterals
