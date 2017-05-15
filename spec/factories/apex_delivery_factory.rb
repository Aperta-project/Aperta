FactoryGirl.define do
  factory :apex_delivery, class: 'TahiStandardTasks::ApexDelivery' do
    user
    paper
    association :task, factory: :ad_hoc_task
  end
end
