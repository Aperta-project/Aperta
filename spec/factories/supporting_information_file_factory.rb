FactoryGirl.define do
  factory :supporting_information_file, parent: :attachment, class: 'SupportingInformationFile' do
    association :owner, factory: :paper
    paper
  end
end
