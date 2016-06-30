FactoryGirl.define do
  factory :figure, parent: :attachment, class: 'Figure' do
    association :owner, factory: :paper
  end
end
