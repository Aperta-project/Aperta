FactoryGirl.define do
  factory :tech_check_task, class: 'StandardTasks::TechCheckTask' do
    phase
    title "Tech Check"
    role "admin"
  end
end
