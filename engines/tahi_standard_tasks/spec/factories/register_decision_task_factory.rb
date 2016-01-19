FactoryGirl.define do
  factory :register_decision_task, class: 'TahiStandardTasks::RegisterDecisionTask' do
    paper
    phase
    title "Register Decision"
    old_role "editor"
  end
end
