FactoryGirl.define do
  factory :register_decision_task, class: 'TahiStandardTasks::RegisterDecisionTask' do
    phase
    title "Register Decision"
    role "editor"

    trait(:with_decision) do
      after(:create) do |task|
        FactoryGirl.create(:decision, paper: task.paper)
      end
    end
  end
end
