FactoryGirl.define do
  factory :manuscript_attachment, parent: :attachment, class: 'ManuscriptAttachment' do
    association :owner, factory: :paper
    paper

    trait :with_filename do
      after :stub do |manuscript_attachment|
        manuscript_attachment[:file] = 'source.docx'
      end
    end

    trait :with_pending_url do
      after :stub do |manuscript_attachment|
        manuscript_attachment.pending_url = 'http://tahi-test.s3.amazonaws.com/temp/source.docx'
      end
    end
  end
end
