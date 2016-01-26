FactoryGirl.define do
  factory :apex_delivery, class: 'TahiStandardTasks::ApexDelivery' do
    user
    paper
    task
  end
end
