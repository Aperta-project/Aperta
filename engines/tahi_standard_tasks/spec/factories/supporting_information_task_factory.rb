FactoryGirl.define do
  factory :supporting_information_task, class: 'TahiSupportingInformation::SupportingInformationTask' do
    phase
    title "Supporting Information"
    role "author"
  end
end
