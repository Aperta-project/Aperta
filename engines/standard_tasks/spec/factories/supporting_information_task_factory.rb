FactoryGirl.define do
  factory :supporting_information_task, class: 'SupportingInformation::SupportingInformationTask' do
    phase
    title "Supporting Information"
    role "author"
  end
end
