FactoryGirl.define do
  factory :export_delivery, class: 'ExportDelivery' do
    user
    paper
    association :task, factory: :ad_hoc_task
  end
end
