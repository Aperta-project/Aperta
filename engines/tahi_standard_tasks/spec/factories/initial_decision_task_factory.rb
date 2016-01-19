FactoryGirl.define do
  factory :initial_decision_task, class: 'TahiStandardTasks::InitialDecisionTask' do
    paper
    phase
    title "Initial Decision"
    old_role "editor"
  end
end
