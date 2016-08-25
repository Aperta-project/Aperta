FactoryGirl.define do
  factory :manuscript_attachment, parent: :attachment, class: 'ManuscriptAttachment' do
    association :owner, factory: :paper
    paper
  end
end
