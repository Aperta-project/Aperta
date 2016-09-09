FactoryGirl.define do
  factory :manuscript_attachment, parent: :attachment, class: 'ManuscriptAttachment' do
    association :owner, factory: :paper
    paper

    trait :with_filename do
      after :stub do |manuscript_attachment|
        manuscript_attachment[:file] = 'source.docx'
      end
    end
  end
end
