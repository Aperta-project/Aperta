FactoryGirl.define do
  factory :apex_delivery, class: 'TahiStandardTasks::ApexDelivery' do
    user
    paper
    association :task, factory: :adhoc_task
  end
end
