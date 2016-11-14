FactoryGirl.define do
  factory :supporting_information_task, class: 'TahiStandardTasks::SupportingInformationTask' do
    paper
    phase
    title "Supporting Information"
  end
end
