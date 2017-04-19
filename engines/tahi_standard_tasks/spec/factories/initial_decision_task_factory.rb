FactoryGirl.define do
  factory :initial_decision_task, class: 'TahiStandardTasks::InitialDecisionTask' do
    paper
    phase
    card_version
    title "Initial Decision"
  end
end
