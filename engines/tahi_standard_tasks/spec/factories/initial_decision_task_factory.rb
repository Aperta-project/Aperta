FactoryGirl.define do
  factory :initial_decision_task, class: 'TahiStandardTasks::InitialDecisionTask' do
    phase
    title "Initial Decision"
    role "editor"
  end
end
