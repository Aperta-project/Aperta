FactoryGirl.define do
  factory :register_decision_task, class: 'TahiStandardTasks::RegisterDecisionTask' do
    paper
    phase
    card_version
    title "Register Decision"
  end
end
