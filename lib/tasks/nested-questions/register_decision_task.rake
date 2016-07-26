# rubocop:disable Metrics/LineLength, Style/StringLiterals

namespace 'nested-questions:seed' do
  task 'register-decision-task': :environment do
    questions = []

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::RegisterDecisionTask.name,
      ident: "register_decision_questions--selected-template",
      value_type: "text",
      text: "Please select a template.",
      position: 1
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::RegisterDecisionTask.name,
      ident: "register_decision_questions--to-field",
      value_type: "text",
      text: "Enter the email here",
      position: 2
    }

    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::RegisterDecisionTask.name,
      ident: "register_decision_questions--subject-field",
      value_type: "text",
      text: "Enter the subject here",
      position: 3
    }

    NestedQuestion.where(
      owner_type: TahiStandardTasks::RegisterDecisionTask.name
    ).update_all_exactly!(questions)
  end
end

# rubocop:enable Metrics/LineLength, Style/StringLiterals
