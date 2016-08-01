FactoryGirl.define do
  factory :supporting_information_file, parent: :attachment, class: 'SupportingInformationFile' do
    association :owner, factory: :supporting_information_task
    paper
  end
end
